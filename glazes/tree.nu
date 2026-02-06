use ../scripts/config.nu [SCOPE OS]
use ../scripts/glaze.nu *
use ../scripts/messages.nu *
use ../scripts/libs/log.nu *
use ../scripts/libs/strings.nu *
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
        --category 'tools'
        --description 'An open-source cross-platform tree cli implemented in Rust.'
        --scope $SCOPE.linux
        --toppings [
            { name: 'tree' url: 'https://github.com/peteretelej/tree' os: $OS.linux package_manager: 'custom' }
        ]
    )
}

def do-install []: nothing -> bool {
    let local_bin_dir: directory = local-bin-dir -m
    let tmp_dir: directory = mktemp -dt

    let tmp_path: path = $tmp_dir | path join 'tree.tar.gz'
    github get peteretelej tree 'tree-v[0-9.]+-Linux-amd64.tar.gz'
    | save -fr $tmp_path

    if ($env.LAST_EXIT_CODE != 0) or not ($tmp_path | path exists) {
        log -l $LOG_LEVEL.fail ($MESSAGE.net_err_download | template { what: "the archive" })
        return false
    }

    log $MESSAGE.arch_info_decompress
    log ($MESSAGE.pkg_info_install | template { what: "executable" })
    let result = decompress $tmp_path $local_bin_dir
    if ($result.success) {
        rm -fr $tmp_dir
    } else {
        log -l $LOG_LEVEL.fail ($MESSAGE.arch_err_decompress | template { error_code: $env.LAST_EXIT_CODE })
        log -l $LOG_LEVEL.note ($MESSAGE.arch_warn_manual | template { what: "archive" target: $tmp_dir })
    }
    $result.success
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
