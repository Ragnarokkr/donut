use ../scripts/config.nu [SCOPE OS]
use ../scripts/glaze.nu *
use ../scripts/messages.nu *
use ../scripts/database.nu  add-environment
use ../scripts/libs/log.nu *
use ../scripts/libs/fs.nu ['path normalize' work-dir data-dir local-bin-dir cp-link]
use ../scripts/libs/net.nu 'github get-archive'
use ../scripts/libs/archive.nu *

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
            { name: 'nudo' url: 'https://github.com/Ragnarokkr/nudo' os: $OS.linux package_manager: 'custom' }
            { name: 'pandoc-bin' url: 'https://pandoc.org/' os: $OS.linux package_manager: 'paru' }
            { name: 'ripgrep' url: 'https://github.com/BurntSushi/ripgrep' os: $OS.linux package_manager: 'pacman' }
            { name: 'tirith' url: 'https://github.com/sheeki03/tirith' os: $OS.linux package_manager: 'cargo' }
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

def do-install []: nothing -> bool {
    # Install nudo
    let tmp_nudo_dir: directory = mktemp -td nudo.XXX
    let tmp_nudo_path: path = $tmp_nudo_dir | path join master.zip
    let source_nudo_dir: directory = $tmp_nudo_dir | path join nudo-master
    let target_nudo_path: path = data-dir -m nudo
    let target_nudo_bin_path: path = local-bin-dir | path join nudo

    github get-archive Ragnarokkr nudo | save -fr $tmp_nudo_path
    let result = decompress $tmp_nudo_path
    if not $result.success { return false }

    let files = glob $"($source_nudo_dir | path normalize)/*"
    $files | each {cp -fru $in $target_nudo_path}
    if not (cp-link -f ($target_nudo_path | path join nudo) $target_nudo_bin_path) { return false }

    rm -frp $tmp_nudo_dir
    true
}

def do-config []: nothing -> bool {
    # Config nudo
    let common_dir = work-dir $ID | get $SCOPE.common
    let source_nudo_config_path = [$common_dir nushell] | path join nudo.nu
    add-environment $ID (open $source_nudo_config_path)
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
