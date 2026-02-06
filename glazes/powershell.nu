use ../scripts/config.nu [SCOPE OS HOOK]
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
    let windows_dir: directory = work-dir $ID | get $SCOPE.windows

    (build-manifest
        $ID
        --category 'shell'
        --description 'Install and configure PowerShell.'
        --scope $SCOPE.windows
        --hook $HOOK.preinstall
        --toppings [
            { name: 'Microsoft.PowerShell' url: 'https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell?view=powershell-7.5' os: $OS.windows package_manager: 'winget' }
        ]
        --files [$"($windows_dir | path normalize)/**/*"]
    )
}

def do-config []: nothing -> bool {
    let windows_dir: directory = work-dir $ID | get $SCOPE.windows
    let cmd = first-available pwsh powershell

    log $MESSAGE.io_info_install_config
    let result = do -i { ^$cmd -ExecutionPolicy bypass -File ($windows_dir | path join 'powershell.ps1') } | complete
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
