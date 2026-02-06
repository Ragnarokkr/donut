use ../scripts/config.nu [SCOPE OS HOOK]
use ../scripts/database.nu [add-environment]
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
    let common_dir: directory = work-dir $ID | get $SCOPE.common

    (build-manifest
        $ID
        --category 'security'
        --description 'Password manager for securely managing and sharing sensitive information.'
        --scope $SCOPE.common
        --hook $HOOK.preinstall
        --toppings [
            { name: 'bitwarden-cli' url: 'https://bitwarden.com/help/cli/' os: $OS.linux package_manager: 'pacman' }
            { name: 'Bitwarden.Bitwarden' url: 'https://bitwarden.com' os: $OS.windows package_manager: 'winget' }
            { name: 'Bitwarden.CLI' url: '{bitwarden-cli.url}' os: $OS.windows package_manager: 'winget' }
        ]
        --files [$"($common_dir | path normalize)/**/*"]
    )
}

def do-config []: nothing -> bool {
    let common_dir: directory = work-dir $ID | get $SCOPE.common

    log $MESSAGE.env_ok_nu_vars
    let source_env_path: path = [$common_dir nushell] | path join 'env.nu'
    mut client_id = ''
    mut client_secret = ''
    loop {
        log -l $LOG_LEVEL.security 'Enter your client_id: '; $client_id = input -s
        log -l $LOG_LEVEL.security 'Enter your client_secret: '; $client_secret = input -s

        if ($client_id | is-not-empty) and ($client_secret | is-not-empty) {
            break;
        } else {
            log -l $LOG_LEVEL.fail "One of required data is missing, please enter it again"
        }
    }

    add-environment --hook $HOOK.preinstall $ID (
        open $source_env_path
        | template { client_id: $'"($client_id)"' client_secret: $'"($client_secret)"' }
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
