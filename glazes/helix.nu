use ../scripts/config.nu [SCOPE OS]
use ../scripts/glaze.nu *
use ../scripts/messages.nu *
use ../scripts/libs/log.nu *
use ../scripts/libs/fs.nu *

const ID = path self | path parse | get stem

# ============================================================================
#                        PRIVATE CUSTOMIZABLE COMMANDS
# ============================================================================

def get-manifest []: nothing -> record {
    let common_dir: directory = work-dir $ID | get $SCOPE.common

    (build-manifest
        $ID
        --category 'editor'
        --description 'A post-modern modal text editor.'
        --scope $SCOPE.common
        --toppings [
            { name: 'helix' url: 'https://docs.helix-editor.com/title-page.html' os: $OS.linux package_manager: 'pacman' }
            { name: 'Helix.Helix' url: '{helix.url}' os: $OS.windows package_manager: 'winget' }
        ]
        --files [$"($common_dir | path normalize)/**/*"]
    )
}

def do-config []: nothing -> bool {
    mut ret = true
    let common_dir: directory = work-dir $ID | get $SCOPE.common
    let target_autoload_dir: directory = $nu.user-autoload-dirs.0
    let target_dir: directory = config-dir -m helix

    log $MESSAGE.io_info_install_config
    for f in (glob $"($common_dir | path normalize)/*.toml") {
        let target_config_path: path = $target_dir | path join ($f | path basename)
        $ret = $ret and (cp-link -f $f $target_config_path)
    }

    log $MESSAGE.env_ok_nu_config
    let source_env_path: path = [$common_dir nushell] | path join 'aliases.nu'
    let target_env_path: path = $target_autoload_dir | path join $"aliases-($ID).nu"
    $ret = $ret and (cp-link -f $source_env_path $target_env_path)

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
