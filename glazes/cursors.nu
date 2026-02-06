use ../scripts/config.nu [SCOPE OS]
use ../scripts/glaze.nu *
use ../scripts/messages.nu *
use ../scripts/libs/log.nu *
use ../scripts/libs/strings.nu *
use ../scripts/libs/system.nu *
use ../scripts/libs/fs.nu *
use ../scripts/libs/archive.nu *

const ID = path self | path parse | get stem

# ============================================================================
#                        PRIVATE CUSTOMIZABLE COMMANDS
# ============================================================================

def get-manifest []: nothing -> record {
    let windows_dir: directory = work-dir $ID | get $SCOPE.windows

    (build-manifest
        $ID
        --category 'ui'
        --description 'Windows 11 Cursors Concept.'
        --scope $SCOPE.windows
        --toppings [
            { name: 'windows_11_cursors_concept_by_jepricreations_densjkc.zip' url: 'https://www.deviantart.com/jepricreations/art/Windows-11-Cursors-Concept-886489356' os: $OS.windows package_manager: 'custom' }
        ]
        --files [$"($windows_dir | path normalize)/**/*"]
    )
}

def do-install []: nothing -> bool {
    let as_root = first-available sudo

    if not (is-admin) and ($as_root == "") {
        log -l $LOG_LEVEL.warning "This must be executed into a terminal with administration privileges"
        return false
    }

    let windows_dir: directory = work-dir $ID | get $SCOPE.windows
    let archive_path: path = $windows_dir | path join 'windows_11_cursors_concept_by_jepricreations_densjkc.zip'

    let result = decompress -t $archive_path
    if not $result.success { return false }

    log ($MESSAGE.pkg_info_install | template { what: "cursors" })
    let install_path: path = [$result.directory windows_11_cursors_concept_by_jepricreations_densjkc light] | path join 'Install.inf'
    let install = do -i {
        if ($as_root != "") {
            do { ^$as_root rundll32.exe setupapi.dll,InstallHinfSection DefaultInstall 128 $install_path }
        } else {
            do { rundll32.exe setupapi.dll,InstallHinfSection DefaultInstall 128 $install_path }
        }
    } | complete
    $install | log

    log -l $LOG_LEVEL.user_input $MESSAGE.ui_info_press_key; input -n 1

    if not ($install.exit_code == 0) {
        log -l $LOG_LEVEL.fail ($MESSAGE.arch_warn_manual | template { what: "cursors" target: $result.directory })
        return false
    }

    rm -fr $result.directory
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
