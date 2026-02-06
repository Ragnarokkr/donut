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
        --category 'network'
        --description 'Various network utilities and tools.'
        --scope $SCOPE.common
        --toppings [
            { name: 'dog' url: 'https://github.com/ogham/dog' os: $OS.linux package_manager: 'pacman' }
            { name: 'inetutils' url: 'https://www.gnu.org/software/inetutils/' os: $OS.linux package_manager: 'pacman' }
            { name: 'iproute2' url: 'https://git.kernel.org/pub/scm/network/iproute2/iproute2.git' os: $OS.linux package_manager: 'pacman' }
            { name: 'net-tools' url: 'http://net-tools.sourceforge.net/' os: $OS.linux package_manager: 'pacman' }
            { name: 'ttl-bin' url: 'https://github.com/lance0/ttl' os: $OS.linux package_manager: 'paru' }
            { name: '9NKSQGP7F2NH' url: 'https://whatsapp.com/' os: $OS.windows package_manager: 'winget' }
            { name: 'amir1376.ABDownloadManager' url: 'https://github.com/amir1376' os: $OS.windows package_manager: 'winget' }
            { name: 'Betterbird.Betterbird' url: 'https://www.betterbird.eu/' os: $OS.windows package_manager: 'winget' }
            { name: 'BiniSoft.WindowsFirewallControl' url: 'https://www.binisoft.org/' os: $OS.windows package_manager: 'winget' }
            { name: 'Brave.Brave.Beta' url: 'https://brave.com' os: $OS.windows package_manager: 'winget' }
            { name: 'BrowserStackInc.Requestly' url: 'https://github.com/requestly' os: $OS.windows package_manager: 'winget' }
            { name: 'DavidMoore.IPFilterUpdater' url: 'https://github.com/DavidMoore/ipfilter' os: $OS.windows package_manager: 'winget' }
            { name: 'LocalSend.LocalSend' url: 'https://localsend.org/' os: $OS.windows package_manager: 'winget' }
            { name: 'Proton.ProtonVPN' url: 'https://protonvpn.com/' os: $OS.windows package_manager: 'winget' }
            { name: 'qBittorrent.qBittorrent' url: 'https://www.qbittorrent.org/' os: $OS.windows package_manager: 'winget' }
            { name: 'WinSCP.WinSCP' url: 'https://winscp.net/' os: $OS.windows package_manager: 'winget' }
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
