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
        --category 'tools'
        --description 'Various tools and utilities for Windows.'
        --scope $SCOPE.windows
        --toppings [
            { name: '9PFXXSHC64H3' url: 'https://www.raycast.com/' os: $OS.windows package_manager: 'winget' }
            { name: '9WZDNCRDXF41' url: 'https://github.com/character-map-uwp/Character-Map-UWP/' os: $OS.windows package_manager: 'winget' }
            { name: 'AstroComma.AstroGrep' url: 'https://astrogrep.sourceforge.net/' os: $OS.windows package_manager: 'winget' }
            { name: 'BleachBit.BleachBit' url: 'https://www.bleachbit.org/' os: $OS.windows package_manager: 'winget' }
            { name: 'Eigenmiao.Rickrack' url: 'https://eigenmiao.com/yanhuo/en.html' os: $OS.windows package_manager: 'winget' }
            { name: 'erengy.Taiga' url: 'https://erengy.com/' os: $OS.windows package_manager: 'winget' }
            { name: 'HakuNeko.HakuNeko' url: 'https://github.com/manga-download/hakuneko' os: $OS.windows package_manager: 'winget' }
            { name: 'hluk.CopyQ' url: 'https://github.com/hluk' os: $OS.windows package_manager: 'winget' }
            { name: 'HulubuluSoftware.AdvancedRenamer' url: 'https://www.advancedrenamer.com/' os: $OS.windows package_manager: 'winget' }
            { name: 'iDescriptor.iDescriptor' url: 'https://github.com/iDescriptor' os: $OS.windows package_manager: 'winget' }
            { name: 'IDRIX.VeraCrypt' url: 'https://www.idrix.fr/' os: $OS.windows package_manager: 'winget' }
            { name: 'JohannesMillan.superProductivity' url: 'https://github.com/super-productivity/super-productivity' os: $OS.windows package_manager: 'winget' }
            { name: 'Microsoft.PowerToys' url: 'https://github.com/microsoft/PowerToys' os: $OS.windows package_manager: 'winget' }
            { name: 'MilosParipovic.OneCommander' url: 'https://onecommander.com/' os: $OS.windows package_manager: 'winget' }
            { name: 'moneymanagerex.moneymanagerex' url: 'https://github.com/moneymanagerex' os: $OS.windows package_manager: 'winget' }
            { name: 'namazso.OpenHashTab' url: 'https://namazso.eu/' os: $OS.windows package_manager: 'winget' }
            { name: 'OlegShparber.Zeal' url: 'https://zealdocs.org/' os: $OS.windows package_manager: 'winget' }
            { name: 'Qalculate.Qalculate' url: 'https://qalculate.github.io/' os: $OS.windows package_manager: 'winget' }
            { name: 'QL-Win.QuickLook' url: 'https://github.com/QL-Win/QuickLook' os: $OS.windows package_manager: 'winget' }
            { name: 'Sandboxie.Plus' url: 'http://xanasoft.com/' os: $OS.windows package_manager: 'winget' }
            { name: 'voidtools.Everything' url: 'https://www.voidtools.com/' os: $OS.windows package_manager: 'winget' }
            { name: 'WinFsp.WinFsp' url: 'https://github.com/winfsp/winfsp' os: $OS.windows package_manager: 'winget' }
            # { name: 'AIM toolkit' url: 'https://sourceforge.net/projects/aim-toolkit/files/latest/download' os: $OS.windows package_manager: 'custom' }
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
