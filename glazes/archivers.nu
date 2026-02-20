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
        --category 'utility'
        --description 'Various high performant archivers.'
        --scope $SCOPE.common
        --toppings [
            { name: '7zip' url: 'https://7-zip.org' os: $OS.linux, package_manager: 'pacman' }
            { name: 'zip' url: 'https://infozip.sourceforge.net/Zip.html' os: $OS.linux, package_manager: 'pacman' }
            { name: 'brotli' url: 'https://github.com/google/brotli' os: $OS.linux package_manager: 'pacman' }
            { name: 'zstd' url: 'https://facebook.github.io/zstd' os: $OS.linux package_manager: 'pacman' }
            { name: 'M2Team.NanaZip.Preview' url: 'https://github.com/M2Team/NanaZip' os: $OS.windows package_manager: 'winget'}
        ]
    )
}

def do-install []: nothing -> bool {
    true
}

def do-config []: nothing -> bool {
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
        (do-install) | to json -r
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
        (do-config) | to json -r
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
