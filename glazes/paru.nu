use ../scripts/config.nu [SCOPE OS HIGHEST_PRIORITY]
use ../scripts/glaze.nu *
use ../scripts/messages.nu *
use ../scripts/libs/log.nu *
use ../scripts/libs/strings.nu *
use ../scripts/libs/system.nu *
use ../scripts/libs/fs.nu *

const ID = path self | path parse | get stem

# ============================================================================
#                        PRIVATE CUSTOMIZABLE COMMANDS
# ============================================================================

def get-manifest []: nothing -> record {
    let linux_dir: directory = work-dir paru | get linux
    let makepkg_dir: directory = work-dir makepkg | get linux

    (build-manifest
        $ID
        --category 'system'
        --description 'AUR helper for pacman.'
        --scope $SCOPE.linux
        --priority ($HIGHEST_PRIORITY + 2)
        --toppings [
            { name: 'paru' url: 'https://aur.archlinux.org/paru.git' os: $OS.linux package_manager: 'custom' }
        ]
        --files [$"($linux_dir | path normalize)/**/*" $"($makepkg_dir | path normalize)/**/*"]
    )
}

def do-install []: nothing -> bool {
    if (is-installed paru) {
        log -l $LOG_LEVEL.warning ($MESSAGE.run_skip | template { module: "paru" action: "install" reason: "already installed" })
        return true
    }

    let tmp_dir: directory = mktemp -dt

    log $"Cloning git repository in ($tmp_dir)"
    let result = do -i { git clone --depth 1 https://aur.archlinux.org/paru.git $tmp_dir } | complete
    $result | log
    if $result.exit_code != 0 { return false }

    log "Building and installing package"
    cd $tmp_dir
    let result = do -i { makepkg -si --noconfirm } | complete
    $result | log
    cd -
    if $result.exit_code != 0 { return false }
    rm -fr $tmp_dir
    true
}

def do-config []: nothing -> bool {
    let linux_dir: directory = work-dir paru | get linux
    let target_dir: directory = config-dir -m paru
    let as_root = first-available doas sudo

    # Prepare the CHROOT building environment for safer packages installation
    # https://wiki.archlinux.org/title/DeveloperWiki:Building_in_a_clean_chroot#Classic_way
    log "configuring safe chroot environment for installations"
    let chroot_dir: directory = "/var/lib/archbuild/extra-x86_64/root"

    let source_config_path: path = $linux_dir | path join 'paru.conf'
    let target_config_path: path = $target_dir | path join 'paru.conf'
    ln -sf $source_config_path $target_config_path | complete | log

    if not ($chroot_dir | path exists) {
        let makepkg_dir: directory = work-dir makepkg | get $SCOPE.linux
        do -i { ^$as_root ln -sf ($makepkg_dir | path join 'makepkg.conf') /etc/makepkg.conf } | complete | log
        do -i { ^$as_root mkdir -p ($chroot_dir | path dirname) } | complete | log
        do -i { ^$as_root mkarchroot $chroot_dir base base-devel } | complete | log
        do -i { ^$as_root arch-nspawn $chroot_dir pacman -Syu } | complete | log
        do -i { ^$as_root mkdir -p /etc/makepkg.conf.d } | complete | log
        do -i { ^$as_root ln -sf ($makepkg_dir | path join 'arch-nspawn.conf') /etc/makepkg.conf.d/arch-nspawn.conf } | complete | log
    }

    $env.LAST_EXIT_CODE == 0
}

# ============================================================================
#                        PUBLIC COMMANDS - DO NOT EDIT
# ============================================================================

# Returns JSON serialized glaze's metadata
def "main manifest" []: nothing -> string {
    log --workspace $ID
    let ret = try {
        { success: true data: (get-manifest) } | to json -r
    } catch {
        $in | log -l $LOG_LEVEL.fail
        { success: false error: 'Unable to retrieve the manifest.' } | to json -r
    }
    log --exit-workspace
    $ret
}

# Installs glaze's package(s)
def "main install" []: nothing -> string {
    log --workspace $ID
    let ret = try {
        if (scope commands | where name == 'do-install' | is-not-empty) {
            do-install
        } else { true }
    } catch {
        $in | log -l $LOG_LEVEL.fail
        false
    }
    log --exit-workspace
    $ret
}

# Installs and configure glaze's dotfiles
def "main config" []: nothing -> string {
    log --workspace $ID
    let ret = try {
        if (scope commands | where name == 'do-config' | is-not-empty) {
            do-config
        } else { true }
    } catch {
        $in | log -l $LOG_LEVEL.fail
        false
    }
    log --exit-workspace
    $ret
}

# Prints out glaze's metadata
def "main info" []: nothing -> record {
    get-manifest | reject files
}

def main [] {}
