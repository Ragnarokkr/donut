use ../scripts/config.nu [SCOPE OS HIGHEST_PRIORITY]
use ../scripts/glaze.nu *
use ../scripts/messages.nu *
use ../scripts/libs/log.nu *
use ../scripts/libs/system.nu *
use ../scripts/libs/fs.nu *

const ID = path self | path parse | get stem

# ============================================================================
#                        PRIVATE CUSTOMIZABLE COMMANDS
# ============================================================================

def get-manifest []: nothing -> record {
    let linux_dir: directory = work-dir $ID | get $SCOPE.linux

    (build-manifest
        $ID
        --category 'system'
        --description 'The Arch Linux package manager.'
        --scope $SCOPE.linux
        --priority ($HIGHEST_PRIORITY + 1)
        --files [$"($linux_dir | path normalize)/**/*"]
    )
}

def do-config []: nothing -> bool {
    let linux_dir: directory = work-dir $ID | get $SCOPE.linux
    let as_root = first-available doas sudo

    log $MESSAGE.io_info_install_config
    let source_config_path: path = $linux_dir | path join 'pacman.conf'
    let target_config_path: path = "/etc/pacman.conf"
    let result = do -i { ^$as_root cp -f $source_config_path $target_config_path } | complete
    $result | log
    $result.exit_code == 0
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
