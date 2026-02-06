use ../scripts/config.nu [SCOPE OS]
use ../scripts/glaze.nu *
use ../scripts/messages.nu *
use ../scripts/database.nu [add-environment]
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
        --category 'shell'
        --description 'A multi-shell multi-command argument completer based on carapace-sh/carapace.'
        --scope $SCOPE.common
        --toppings [
            { name: 'carapace-bin' url: 'https://carapace-sh.github.io/carapace-bin/carapace-bin.html' os: $OS.linux package_manager: 'paru' }
            { name: 'rsteube.Carapace' url: '{carapace-bin.url}' os: $OS.windows package_manager: 'winget' }
        ]
        --files [$"($common_dir | path normalize)/**/*"]
    )
}

def do-config []: nothing -> bool {
    let common_dir: directory = work-dir $ID | get $SCOPE.common
    let target_autoload_dir: directory = $nu.user-autoload-dirs.0

    log $MESSAGE.env_ok_nu_cmds
    let source_config_path: path = [$common_dir nushell] | path join 'carapace.nu'
    let target_config_path: path = [$target_autoload_dir] | path join 'carapace.nu'
    cp-link -f $source_config_path $target_config_path

    log $MESSAGE.env_ok_nu_vars
    let source_env_path: path = [$common_dir nushell env.nu] | path join
    add-environment $ID (open $source_env_path)

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
