use ../scripts/config.nu [SCOPE OS]
use ../scripts/glaze.nu *
use ../scripts/messages.nu *
use ../scripts/libs/log.nu *

const ID = path self | path parse | get stem

# ============================================================================
#                        PRIVATE CUSTOMIZABLE COMMANDS
# ============================================================================

def get-manifest []: nothing -> record {
    (build-manifest
        $ID
        --category 'media'
        --description 'Create beautiful film credits without the pain.'
        --scope $SCOPE.windows
        --toppings [
            { name: 'cinecred' url: 'https://github.com/LoadingByte/cinecred' os: $OS.windows package_manager: 'custom' }
        ]
    )
}

def do-install []: nothing -> bool {
    const HOST_NAME = 'https://cinecred.com'
    let tmp_dir: directory = mktemp -dt
    let tmp_path: path = [$tmp_dir cinecred-setup.msi] | path join

    log $MESSAGE.pkg_info_get_installer
    let response = (if (net has-connection) {
        http get $HOST_NAME
            | query webpage-info
            | get links | find -ir '/dl/[0-9.]+/cinecred-[0-9.]+-x86_64\.msi'
    })

    if ($response | is-empty) {
        log -l $LOG_LEVEL.error $MESSAGE.pkg_err_no_installer
        return false
    }

    if (net has-connection) {
        let url = $"($HOST_NAME)($response | get url.0 | ansi strip)"
        http get $url | save -fr $tmp_path
        if ($env.LAST_EXIT_CODE != 0) or not ($tmp_path | path exists) {
            log -l $LOG_LEVEL.fail (msg $MESSAGE.net_err_download {what: "the installer"})
            return false
        }

        do -i { ^$tmp_path } | complete | log -l $LOG_LEVEL.install
        log -l $LOG_LEVEL.user_input $MESSAGE.ui_info_press_key; input -n 1
        rm -fr $tmp_dir
        true
    } else { false }
}

def do-setup []: nothing -> bool {
    true
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
