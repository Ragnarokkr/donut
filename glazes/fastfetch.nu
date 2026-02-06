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
        --category 'system'
        --description 'A maintained, feature-rich and performance oriented, neofetch like system information tool.'
        --scope $SCOPE.common
        --toppings [
            { name: 'fastfetch' url: 'https://github.com/fastfetch-cli/fastfetch' os: $OS.linux package_manager: 'pacman' }
            { name: 'Fastfetch-cli.Fastfetch' url: '{fastfetch.url}' os: $OS.windows package_manager: 'winget' }
        ]
        --files [$"($common_dir | path normalize)/**/*"]
    )
}

def do-config []: nothing -> bool {
    let common_dir: directory = work-dir $ID | get $SCOPE.common
    let target_dir: directory = config-dir -m fastfetch

    log $MESSAGE.io_info_install_config
    let source_config_path: path = $common_dir | path join 'config.jsonc'
    let target_config_path: path = $target_dir | path join 'config.jsonc'
    cp-link -f $source_config_path $target_config_path
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
