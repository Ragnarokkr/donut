use ../scripts/config.nu [SCOPE HOOK OS HIGHEST_PRIORITY]
use ../scripts/glaze.nu *
use ../scripts/libs/log.nu *

const ID = path self | path parse | get stem

# ============================================================================
#                        PRIVATE CUSTOMIZABLE COMMANDS
# ============================================================================

def get-manifest []: nothing -> record {
    (build-manifest
        $ID
        --category 'system'
        --description 'Base system packages and configuration.'
        --scope $SCOPE.common
        --hook $HOOK.preinstall
        --priority $HIGHEST_PRIORITY
        --toppings [
            { name: 'opendoas' url: 'https://github.com/Duncaen/OpenDoas' os: $OS.linux package_manager: 'pacman' }
            { name: 'base-devel' url: 'https://www.archlinux.org' os: $OS.linux package_manager: 'pacman' }
            { name: 'devtools' url: 'https://gitlab.archlinux.org/archlinux/devtools' os: $OS.linux package_manager: 'pacman' }
            { name: 'unzip' url: 'http://infozip.sourceforge.net/UnZip.html' os: $OS.linux package_manager: 'pacman' }
            { name: 'man-db' url: 'https://gitlab.com/man-db/man-db' os: $OS.linux package_manager: 'pacman' }
            { name: 'man-pages' url: 'https://www.kernel.org/doc/man-pages' os: $OS.linux package_manager: 'pacman' }
            { name: 'openssh' url: 'https://www.openssh.com/portable.html' os: $OS.linux package_manager: 'pacman' }
            { name: 'intel-ucode' url: 'https://github.com/intel/Intel-Linux-Processor-Microcode-Data-Files' os: $OS.linux package_manager: 'pacman' }
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
