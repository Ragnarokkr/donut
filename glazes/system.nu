use ../scripts/config.nu [HOOK SCOPE OS HIGHEST_PRIORITY]
use ../scripts/glaze.nu [build-manifest]
use ../scripts/libs/log.nu *
use ../scripts/libs/strings.nu *
use ../scripts/libs/system.nu [first-available]
use ../scripts/libs/fs.nu *

const ID = path self | path parse | get stem

# ============================================================================
#                        PRIVATE CUSTOMIZABLE COMMANDS
# ============================================================================

def get-manifest []: nothing -> record {
    let linux_dir = work-dir $ID | get $SCOPE.linux

    (build-manifest
        $ID
        --category 'system'
        --description 'System-wide customization'
        --hook $HOOK.preinstall
        --scope $SCOPE.linux
        --priority ($HIGHEST_PRIORITY + 2)
    )
}

def do-config []: nothing -> bool {
    mut ret = true
    let as_root = first-available doas sudo

    log ($"Enabling ($LOG_TYPE.source.ansi_open){locales}($LOG_TYPE.source.ansi_close) locales..."
        | template { locales: ([it_IT en_US] | str join ', ')})
    const LOCALE_GEN_PATH: path = '/etc/locale.gen'
    let locale_gen: string = open $LOCALE_GEN_PATH
    | str replace '#en_US.UTF-8 UTF-8' 'en_US.UTF-8 UTF-8'
    | str replace '#it_IT.UTF-8 UTF-8' 'it_IT.UTF-8 UTF-8'
    let result = do -i { ^$as_root nu -c $"echo '($locale_gen)' | save -f ($LOCALE_GEN_PATH)" } | complete
    $ret = $ret and ($result.exit_code == 0)
    $result | log

    log 'Generating locales...'
    let result = do -i { ^$as_root locale-gen } | complete
    $ret = $ret and ($result.exit_code == 0)
    $result | log

    log 'Setting current locale...'
    let result = do -i { ^$as_root localectl set-locale LANG=it_IT.UTF8 } | complete
    $ret = $ret and ($result.exit_code == 0)
    $result | log

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
