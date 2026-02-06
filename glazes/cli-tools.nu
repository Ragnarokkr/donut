use ../scripts/config.nu [SCOPE OS]
use ../scripts/glaze.nu *
use ../scripts/messages.nu *
use ../scripts/libs/log.nu *

const ID = path self | path parse | get stem

# ============================================================================
#                        PRIVATE CUSTOMIZABLE COMMANDS
# ============================================================================

def get-manifest []: nothing -> record {
    (build-manifest
        $ID
        --category 'utility'
        --description 'Command-line tools for various tasks.'
        --scope $SCOPE.common
        --toppings [
            { name: 'bat' url: 'https://github.com/sharkdp/bat' os: $OS.linux package_manager: 'pacman' }
            { name: 'cmark-gfm' url: 'https://github.com/github/cmark-gfm' os: $OS.linux package_manager: 'pacman' }
            { name: 'diff-so-fancy' url: 'https://github.com/so-fancy/diff-so-fancy' os: $OS.linux package_manager: 'pacman' }
            { name: 'fzf' url: 'https://github.com/junegunn/fzf' os: $OS.linux package_manager: 'pacman' }
            { name: 'glow' url: 'https://github.com/charmbracelet/glow' os: $OS.linux package_manager: 'pacman' }
            { name: 'hevi-bin' url: 'https://codeberg.org/arnauc/hevi' os: $OS.linux package_manager: 'paru' }
            { name: 'hyperfine' url: 'https://github.com/sharkdp/hyperfine' os: $OS.linux package_manager: 'pacman' }
            { name: 'just' url: 'https://github.com/casey/just' os: $OS.linux package_manager: 'pacman' }
            { name: 'pandoc-bin' url: 'https://pandoc.org/' os: $OS.linux package_manager: 'paru' }
            { name: 'ripgrep' url: 'https://github.com/BurntSushi/ripgrep' os: $OS.linux package_manager: 'pacman' }
            { name: 'tokei' url: 'https://github.com/XAMPPRocky/tokei' os: $OS.linux package_manager: 'pacman' }
            { name: 'typst' url: 'https://typst.app' os: $OS.linux package_manager: 'pacman' }
            { name: 'wl-clipboard' url: 'https://github.com/bugaevc/wl-clipboard' os: $OS.linux package_manager: 'pacman' }
            { name: 'Arnau478.hevi' url: '{hevi-bin.url}' os: $OS.windows package_manager: 'winget' }
            { name: 'Casey.Just' url: '{just.url}' os: $OS.windows package_manager: 'winget' }
            { name: 'charmbracelet.glow' url: '{glow.url}' os: $OS.windows package_manager: 'winget' }
            { name: 'junegunn.fzf' url: '{fzf.url}' os: $OS.windows package_manager: 'winget' }
            { name: 'sharkdp.bat' url: '{bat.url}' os: $OS.windows package_manager: 'winget' }
            { name: 'sharkdp.hyperfine' url: '{hyperfine.url}' os: $OS.windows package_manager: 'winget' }
            { name: 'JohnMacFarlane.Pandoc' url: '{pandoc-bin.url}' os: $OS.windows package_manager: 'winget' }
            { name: 'Typst.Typst' url: '{typst.url}' os: $OS.windows package_manager: 'winget' }
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
