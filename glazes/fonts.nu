use ../scripts/config.nu [SCOPE OS]
use ../scripts/glaze.nu *
use ../scripts/messages.nu *
use ../scripts/libs/log.nu *
use ../scripts/libs/strings.nu *
use ../scripts/libs/net.nu ['github get']
use ../scripts/libs/archive.nu *

const ID = path self | path parse | get stem

# ============================================================================
#                        PRIVATE CUSTOMIZABLE COMMANDS
# ============================================================================

const FONTS_TBL: table = [
    {
        repo: [JetBrains JetBrainsMono]
        pattern: '^(JetBrainsMono-[0-9.]+\.zip)$',
        filename: "JetBrainsMono.zip",
        glob: "fonts/variable/JetBrainsMono*.ttf"
    },
    {
        repo: [ryanoasis nerd-fonts],
        pattern: '^(JetBrainsMono\.zip)$',
        filename: "JetBrainsMonoNerdFont.zip",
        glob: "JetBrainsMonoNerdFontPropo*.ttf"
    },
    {
        repo: [rsms inter],
        pattern: '^(Inter-[0-9.]+\.zip)$',
        filename: "Inter.zip",
        glob: "InterVariable*.ttf"
    }
]

def get-manifest []: nothing -> record {
    (build-manifest
        $ID
        --category 'ui'
        --description 'Cool fonts for developing.'
        --scope $SCOPE.windows
        --toppings [
            { name: 'JetBrainsMono' url: 'https://github.com/JetBrains/JetBrainsMono' os: $OS.windows package_manager: 'custom' }
            { name: 'JetBrainsMono Nerd Fonts' url: 'https://github.com/ryanoasis/nerd-fonts' os: $OS.windows package_manager: 'custom' }
            { name: 'Inter' url: 'https://github.com/rsms/inter' os: $OS.windows package_manager: 'custom' }
        ]
    )
}

def do-install []: nothing -> bool {
    mut ret = true
    let user_fonts_dir: directory = [$env.LOCALAPPDATA Microsoft Windows] | path join 'Fonts'
    let tmp_dir: directory = mktemp -dt

    for font in $FONTS_TBL {
        let font_path: path = $tmp_dir | path join $font.filename
        let font_dir: directory = $tmp_dir | path join ($font.filename | path parse | get stem)

        github get ($font.repo.0) ($font.repo.1) ($font.pattern)
        | save -fr ($tmp_dir | path join $font.filename)

        if $env.LAST_EXIT_CODE != 0 { $ret = false; continue }

        let result = decompress $font_path $font_dir
        if not $result.success { $ret = false; continue }

        log ($MESSAGE.pkg_info_install | template { what: $font_path })
        cd $font_dir
        for f in (glob -D $font.glob) {
            let font_parse = $f | path parse
            let user_font_path: path = $user_fonts_dir | path join $"($font_parse.stem).($font_parse.extension)"
            cp -fu $f $user_font_path
            $ret = $ret and $env.LAST_EXIT_CODE == 0
        }
        cd -

        if $ret { rm -fr $font_dir $font_path }
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
