use ../scripts/config.nu [SCOPE OS]
use ../scripts/glaze.nu *
use ../scripts/messages.nu *
use ../scripts/database.nu [add-environment]
use ../scripts/libs/log.nu *
use ../scripts/libs/system.nu *
use ../scripts/libs/fs.nu *

const ID = path self | path parse | get stem

# ============================================================================
#                        PRIVATE CUSTOMIZABLE COMMANDS
# ============================================================================

def get-manifest []: nothing -> record {
    let common_dir: directory = work-dir $ID | get $SCOPE.common
    let linux_dir: directory = work-dir $ID | get $SCOPE.linux

    (build-manifest
        $ID
        --category 'security'
        --description 'A complete and free implementation of the OpenPGP standard to encrypt and sign your data and communications.'
        --scope $SCOPE.common
        --toppings [
            { name: 'gnupg' url: 'https://www.gnupg.org/' os: $OS.linux package_manager: 'pacman' }
            { name: 'GnuPG.Gpg4win' url: 'https://www.gpg4win.org/' os: $OS.windows package_manager: 'winget' }
        ]
        --files [$"($common_dir | path normalize)/**/*" $"($linux_dir | path normalize)/**/*"]
    )
}

def do-config []: nothing -> bool {
    mut ret = true
    let common_dir: directory = work-dir $ID | get $SCOPE.common
    let linux_dir: directory = work-dir $ID | get $SCOPE.linux
    let target_autoload_dir: directory = $nu.user-autoload-dirs.0
    let target_dir: directory = match (get-os) {
        $os if $os == $OS.linux => { home-dir -m .gnupg }
        $os if $os == $OS.windows => { config-dir -m gnupg }
    }

    log $MESSAGE.io_info_install_config
    let source_config_path: path = $common_dir | path join 'gpg.conf'
    let target_config_path: path = $target_dir | path join 'gpg.conf'
    $ret = $ret and (cp-link -f $source_config_path $target_config_path)

    if (is-linux) {
       log $MESSAGE.env_ok_nu_vars
       let source_env_path: path = [$linux_dir nushell] | path join 'env.nu'
       add-environment $ID (open $source_env_path)

       log -l $LOG_LEVEL.note $"remember to import your private keys via ($LOG_TYPE.command.ansi_open)gpg --import <private_key_file>(ansi reset)"
    }

    $ret
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
