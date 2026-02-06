use ../scripts/config.nu [SCOPE OS]
use ../scripts/glaze.nu *
use ../scripts/libs/log.nu *

const ID = path self | path parse | get stem

# ============================================================================
#                        PRIVATE CUSTOMIZABLE COMMANDS
# ============================================================================

def get-manifest []: nothing -> record {
    (build-manifest
        $ID
        --category 'media'
        --description 'Various media-related tools and utilities.'
        --scope $SCOPE.common
        --toppings [
            { name: 'ffmpeg' url: 'https://ffmpeg.org' os: $OS.linux package_manager: 'pacman' }
            { name: 'imagemagick' url: 'https://www.imagemagick.org/' os: $OS.linux package_manager: 'pacman' }
            { name: 'Canva.Affinity' url: 'https://www.affinity.studio/' os: $OS.windows package_manager: 'winget' }
            { name: 'PaulPacifico.ShutterEncoder' url: 'https://www.shutterencoder.com/' os: $OS.windows package_manager: 'winget' }
            { name: 'ReincubateLtd.CamoStudio' url: 'https://reincubate.com/' os: $OS.windows package_manager: 'winget' }
            { name: 'Spotify.Spotify' url: 'https://www.spotify.com/' os: $OS.windows package_manager: 'winget' }
            { name: 'VideoLAN.VLC' url: 'https://www.videolan.org/' os: $OS.windows package_manager: 'winget' }
            { name: 'XnSoft.XnViewMP' url: 'https://www.xnview.com/en/' os: $OS.windows package_manager: 'winget' }
        ]
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
