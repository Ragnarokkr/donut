use ../scripts/config.nu [SCOPE OS]
use ../scripts/glaze.nu *
use ../scripts/libs/log.nu *
use ../scripts/libs/fs.nu *
use ../scripts/libs/net.nu ['github get']

const ID = path self | path parse | get stem

# ============================================================================
#                        PRIVATE CUSTOMIZABLE COMMANDS
# ============================================================================

def get-manifest []: nothing -> record {
    (build-manifest
        $ID
        --category 'utility'
        --description 'Reference Image Viewer.'
        --scope $SCOPE.disabled
        --toppings [
            { name: 'BeeRef' url: 'https://github.com/rbreu/beeref' os: $OS.windows package_manager: 'custom' }
        ]
    )
}

def do-install []: nothing -> bool {
    let target_path: path = (local-bin-dir -m) | path join 'BeeRef.exe'
    github get rbreu beeref 'BeeRef-[0-9.]+\.exe'
    | save -fr $target_path
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
