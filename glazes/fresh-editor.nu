use ../scripts/config.nu [SCOPE OS]
use ../scripts/glaze.nu *
use ../scripts/messages.nu *
use ../scripts/libs/log.nu *
use ../scripts/libs/strings.nu *
use ../scripts/libs/system.nu *
use ../scripts/libs/fs.nu *
use ../scripts/libs/net.nu ['github get']
use ../scripts/libs/archive.nu *

const ID = path self | path parse | get stem

# ============================================================================
#                        PRIVATE CUSTOMIZABLE COMMANDS
# ============================================================================

def get-manifest []: nothing -> record {
    (build-manifest
        $ID
        --category 'editor'
        --description 'Text editor for your terminal: easy, powerful and fast.'
        --scope $SCOPE.common
        --toppings [
            { name: 'fresh-editor-bin' url: 'https://github.com/sinelaw/fresh' os: $OS.linux package_manager: 'paru' }
            { name: 'fresh-editor' url: '{fresh-editor-bin.url}' os: $OS.windows package_manager: 'custom' }
        ]
    )
}

def do-install []: nothing -> bool {
    if (is-windows) {
        let tmp_dir: directory = mktemp -dt
        let tmp_path: path = $tmp_dir | path join 'download.zip'
        let unarchive_dir: directory = $tmp_dir | path join 'archive'
        let target_dir: directory = local-bin-dir fresh-editor

        github get sinelaw fresh 'fresh-editor-x86_64-pc-windows-msvc.zip'
        | save -fr $tmp_path

        if ($env.LAST_EXIT_CODE != 0) or not ($tmp_path | path exists) {
            log -l $LOG_LEVEL.fail ($MESSAGE.usr_get_error | template { what: "the archive" })
            return false
        }

        let result = decompress $tmp_path $unarchive_dir
        if not $result.success { return false }

        rm -fr $target_dir
        mv $unarchive_dir $target_dir
        if $env.LAST_EXIT_CODE != 0 {
            log -l $LOG_LEVEL.fail ($MESSAGE.arch_err_decompress | template { error_code: $env.LAST_EXIT_CODE })
            return false
        }

        rm -fr $tmp_dir
        true
    } else {
        false
    }
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
