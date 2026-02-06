use ../scripts/config.nu [SCOPE OS]
use ../scripts/glaze.nu *
use ../scripts/messages.nu *
use ../scripts/libs/log.nu *
use ../scripts/libs/strings.nu *
use ../scripts/libs/fs.nu *

const ID = path self | path parse | get stem

# ============================================================================
#                        PRIVATE CUSTOMIZABLE COMMANDS
# ============================================================================

def get-manifest []: nothing -> record {
    let windows_dir: directory = work-dir $ID | get $SCOPE.windows

    (build-manifest
        $ID
        --category 'shell'
        --description 'The new Windows Terminal and the original Windows console host.'
        --scope $SCOPE.windows
        --toppings [
            { name: 'Microsoft.WindowsTerminal' url: 'https://github.com/microsoft/terminal' os: $OS.windows package_manager: 'winget' }
        ]
        --files [$"($windows_dir | path normalize)/**/*"]
    )
}

def do-config []: nothing -> bool {
    let windows_dir: directory = work-dir $ID | get $SCOPE.windows
    let target_dir: directory = [$env.LOCALAPPDATA Packages Microsoft.WindowsTerminal_8wekyb3d8bbwe] | path join 'LocalState'

    log ($MESSAGE.io_info_config | template { what: $"settings in ($target_dir)/settings.json" })
    let source_config_path: path = $windows_dir | path join 'settings.json'
    let target_config_path: path = $target_dir | path join 'settings.json'
    open $target_config_path
    | merge deep (open $source_config_path)
    | save -f $target_config_path
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
