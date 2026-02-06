use ../scripts/config.nu [SCOPE OS]
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
    let windows_dir: directory = work-dir $ID | get $SCOPE.windows

    (build-manifest
        $ID
        --category 'ui'
        --description 'A collection of free wallpapers.'
        --scope $SCOPE.windows
        --files [$"($windows_dir | path normalize)/**/*"]
    )
}

def do-install []: nothing -> bool {
    mut ret = true
    let windows_dir: directory = work-dir $ID | get $SCOPE.windows
    let target_dir: directory = home-dir -m (Pictures | path join 'wallpapers')
    let menu = [
        [id title];
        [1 "Faster: install local repo's wallpapers"]
        [2 "Fast: install local repo's optimized wallpapers"]
    ]

    match ($menu | input list -d title).id {
        1 => {
            log ($MESSAGE.pkg_info_install | template { what: "wallpapers" })
            for $f in (glob $"($windows_dir | path normalize)/*.jpg") {
                let target_wallpaper_path: path = $target_dir | path join ($f | path basename)
                $ret = $ret and (cp-link -f $f $target_wallpaper_path)
            }
        }
        2 => {
            log ($MESSAGE.pkg_info_install | template { what: "optimized wallpapers" })
            for $f in (glob $"($windows_dir | path normalize)/*.jpg") {
                let target_wallpaper_path: path = $target_dir | path join $"($f | path parse | get stem).jxl"
                let result = do -i { cjxl $f $target_wallpaper_path } | complete
                $result | log
                $ret = $ret and ($result.exit_code == 0)
            }
        }
    }

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
