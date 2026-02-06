use ../scripts/config.nu [SCOPE OS]
use ../scripts/glaze.nu *
use ../scripts/messages.nu *
use ../scripts/libs/log.nu *
use ../scripts/libs/strings.nu *
use ../scripts/libs/fs.nu *
use ../scripts/libs/net.nu *

const ID = path self | path parse | get stem

# ============================================================================
#                        PRIVATE CUSTOMIZABLE COMMANDS
# ============================================================================

def get-manifest []: nothing -> record {
    let windows_dir: directory = work-dir $ID | get $SCOPE.windows

    (build-manifest
        $ID
        --category 'editor'
        --description 'A minimal code editor crafted for speed and collaboration with humans and AI.'
        --scope $SCOPE.windows
        --toppings [
            { name: 'ZedIndustries.Zed' url: 'https://zed.dev/' os: $OS.windows package_manager: 'winget' }
        ]
        --files [$"($windows_dir | path normalize)/**/*"]
        --dependencies ['bitwarden']
    )
}

def do-config []: nothing -> bool {
    let windows_dir: directory = work-dir $ID | get $SCOPE.windows
    let target_dir: directory = config-dir -m zed

    log ($MESSAGE.io_info_config | template { what: "settings" })
    let source_settings_path: path = $windows_dir | path join 'settings.json'
    let target_settings_path: path = $target_dir | path join 'settings.json'

    log -l $LOG_LEVEL.security $MESSAGE.ui_info_bw_pass
    let response = if (has-connection) { do { bw get item "Context7" --response } | from json } else { null }
    if ($response == null) { return false }
    if not ($response.success) {
        log -l $LOG_LEVEL.fail $"Unable to retrieve the Context7 api key: ($LOG_TYPE.error.ansi_open)\(($response.message))(ansi reset)"
        false
    }
    let context7_api_key = $response.data | get fields | where name == "API Key (Zed)" | get value.0
    if not ($target_settings_path | path exists) {
        open $source_settings_path
        | update context_servers.mcp-server-context7.settings.context7_api_key $context7_api_key
        | save -f $target_settings_path
    } else {
        open $target_settings_path
        | merge deep (open $source_settings_path)
        | update context_servers.mcp-server-context7.settings.context7_api_key $context7_api_key
        | save -f $target_settings_path
    }
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
