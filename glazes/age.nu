use ../scripts/config.nu [SCOPE OS HIGHEST_PRIORITY]
use ../scripts/messages.nu *
use ../scripts/glaze.nu *
use ../scripts/database.nu [add-environment]
use ../scripts/libs/log.nu *
use ../scripts/libs/strings.nu *
use ../scripts/libs/system.nu *
use ../scripts/libs/fs.nu *
use ../scripts/libs/net.nu ['bitwarden get']

const ID = path self | path parse | get stem

# ============================================================================
#                        PRIVATE CUSTOMIZABLE COMMANDS
# ============================================================================

def get-manifest []: nothing -> record {
    let common_dir: directory = work-dir $ID | get $SCOPE.common

    (build-manifest
        $ID
        --category 'security'
        --description 'A simple, secure, and modern encryption tool.'
        --priority $HIGHEST_PRIORITY
        --toppings [
            { name: 'age' url: 'https://github.com/FiloSottile/age' os: $OS.linux package_manager: 'pacman' }
            { name: 'FiloSottile.age' url: '{age.url}' os: $OS.windows package_manager: 'winget' }
        ]
        --dependencies ['bitwarden']
        --files [$"($common_dir | path normalize)/**/*"]
    )
}

def do-config []: nothing -> bool {
    mut ret = true
    let common_dir: directory = work-dir $ID | get $SCOPE.common
    let target_autoload_dir: directory = $nu.user-autoload-dirs.0
    let target_config_dir: directory = config-dir -m $ID

    # Retrieve the content of the private key file
    log $"Configuring private key file in ($LOG_TYPE.target.ansi_open)($target_config_dir)(ansi reset)"
    let target_prv_key_path: path = $target_config_dir | path join 'key.txt'
    let response = bitwarden get 'Filosottile Age Key'
    $ret = $ret and (if not $response.success {
        log -l $LOG_LEVEL.error $"Unable to retrieve the private key \(($LOG_TYPE.error.ansi_open)$($response.message)($LOG_TYPE.error.ansi_close))(ansi reset)"
        return false
    } else {
        $response.data.notes | save -f $target_prv_key_path
        true
    })

    # Configure the environment data
    log $MESSAGE.env_ok_nu_vars
    let source_env_path: path = [$common_dir nushell] | path join 'env.nu'
    $ret = $ret and (add-environment $ID (
        open $source_env_path
        | template { age_key_file: $'"($target_prv_key_path | path normalize)"' }
    ))

    # Installs custom commands
    log $MESSAGE.env_ok_nu_cmds
    let source_command_path: path = [$common_dir nushell] | path join 'commands.nu'
    let target_command_path: path = [$target_autoload_dir] | path join $"commands-($ID).nu"
    $ret = $ret and (cp-link -f $source_command_path $target_command_path)

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
