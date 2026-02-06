use ../scripts/config.nu [SCOPE OS HIGHEST_PRIORITY]
use ../scripts/glaze.nu [build-manifest]
use ../scripts/messages.nu *
use ../scripts/database.nu [add-environment]
use ../scripts/libs/log.nu *
use ../scripts/libs/strings.nu *
use ../scripts/libs/fs.nu *
use ../scripts/libs/net.nu ['bitwarden get']

const ID = path self | path parse | get stem

# ============================================================================
#                        PRIVATE CUSTOMIZABLE COMMANDS
# ============================================================================

def get-manifest []: nothing -> record {
    let linux_dir = work-dir $ID | get $SCOPE.linux

    (build-manifest
        $ID
        --category 'development'
        --description 'The open source AI coding agent.'
        --scope $SCOPE.linux
        --toppings [
            { name: 'opencode-bin' url: 'https://opencode.ai' os: $OS.linux package_manager: 'paru' }
        ]
        --dependencies ['bitwarden']
        --files [$"($linux_dir | path normalize)/**/*"]
    )
}

# def do-install []: nothing -> bool {}

def do-config []: nothing -> bool {
    let linux_dir = work-dir $ID | get $SCOPE.linux

    let result = bitwarden get 'Gemini AI'
    if not $result.success {
        log -l $LOG_LEVEL.error ($MESSAGE.net_err_bw_get | template { item: 'Gemini AI' message: $result.message? })
        return false
    }

    # Configure the environment data
    log $MESSAGE.env_ok_nu_vars
    let $gemini_api_key = $result.data.login.password
    let source_env_path: path = [$linux_dir nushell] | path join 'env.nu'
    add-environment $ID (
        open $source_env_path
        | template { gemini_api_key: $gemini_api_key }
    )
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
