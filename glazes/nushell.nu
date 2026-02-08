use ../scripts/config.nu [SCOPE OS HOOK HIGHEST_PRIORITY]
use ../scripts/glaze.nu *
use ../scripts/messages.nu *
use ../scripts/database.nu [add-environment]
use ../scripts/libs/log.nu *
use ../scripts/libs/system.nu *
use ../scripts/libs/fs.nu *

const ID = path self | path parse | get stem

# ============================================================================
#                        PRIVATE CUSTOMIZABLE COMMANDS
# ============================================================================

def get-manifest []: nothing -> record {
    let common_dir: directory = work-dir $ID | get $SCOPE.common
    let os_dir: directory = work-dir $ID | get (get-os)

    (build-manifest
        $ID
        --category 'shell'
        --description 'Nushell is a powerful, modern, and intuitive shell for the command line.'
        --scope $SCOPE.common
        --priority ($HIGHEST_PRIORITY + 1)
        --hook $HOOK.preinstall
        --files [$"($common_dir | path normalize)/**/*" $"($os_dir | path normalize)/**/*"]
    )
}

def do-config []: nothing -> bool {
    mut ret = true
    let common_dir: directory = work-dir $ID | get $SCOPE.common
    let os_dir: directory = work-dir $ID | get (get-os)
    let target_autoload_dir: directory = $nu.user-autoload-dirs.0

    # initialize the user autoload directory
    mkdir $target_autoload_dir

    # set the config.nu file
    log $MESSAGE.io_info_install_config
    let source_config_path: path = $common_dir | path join 'config.nu'
    # NOTE: Avoid using `$nu.config-path` here to prevent overwriting the source `config.nu` file.
    let target_config_path: path = $nu.default-config-dir | path join 'config.nu'
    $ret = $ret and (cp-link -f $source_config_path $target_config_path)

    # set the env.nu file
    log $MESSAGE.env_ok_nu_vars
    let $source_env_path: path = $os_dir | path join 'env.nu'
    $ret = $ret and (add-environment --hook $HOOK.preinstall $ID (open $source_env_path) --priority $HIGHEST_PRIORITY)

    # install common and OS-related scripts
    log $MESSAGE.env_ok_nu_config
    $ret = $ret and (
        glob $"($common_dir | path normalize)/autoload/*"
        | each {|p| cp-link -f $p ($target_autoload_dir | path join ($p | path basename))}
        | all {}
    ) and (
        glob $"($os_dir | path normalize)/autoload/*"
        | each {
            let source_parse = $in | path parse
            let target_config_path: path = $target_autoload_dir | path join $"($source_parse.stem)-(get-os).($source_parse.extension)"
            cp-link -f $in $target_config_path
        }
        | all {}
    ) and (
        glob -D $"($common_dir | path normalize)/scripts/**"
        | each {|p|
            let target_script_dir: directory = $nu.default-config-dir | path join scripts
            let target_script_path: path = $p | str replace ($common_dir | path join scripts) '' | str trim -l -c (char path_sep)
            mkdir ([$target_script_dir] | path join $target_script_path | path dirname)
            cp-link -f $p ([$target_script_dir] | path join $target_script_path)}
        | all {}
    )

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
