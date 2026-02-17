use ../scripts/config.nu [SCOPE OS]
use ../scripts/glaze.nu *
use ../scripts/messages.nu *
use ../scripts/libs/log.nu *
use ../scripts/libs/strings.nu *
use ../scripts/libs/fs.nu *
use ../scripts/libs/net.nu *

const ID = path self | path parse | get stem

# ============================================================================
#                        PRIVATE CUSTOMIZABLE COMMANDS
# ============================================================================

def get-plugins [] {
    [
        {
            name: 'saumyajyoti/omp'
            body: ('require("omp"):setup({ config = "{config}" })'
                | template { config: (config-dir oh-my-posh | path join 'atomic-custom.omp.json') })
        }
        { name: 'kmlupreti/ayu-dark' body: '' }
    ]
}

def update-init [
    plugin: string
    body: string
] {
    if (body == "") { return true }

    let target_dir: directory = config-dir yazi
    let init_path: path = $target_dir | path join 'init.lua'

    if (open $target_dir | str contains $"require\(\"($plugin)\"\):setup") { return true }
    try { $body | save -a $init_path; true } catch { false }
}

def get-manifest []: nothing -> record {
    let linux_dir: directory = work-dir $ID | get $SCOPE.linux

    (build-manifest
        $ID
        --category 'tools'
        --description 'Blazing fast terminal file manager written in Rust, based on async I/O.'
        --scope $SCOPE.disabled
        --toppings [
            { name: 'yazi' url: 'https://github.com/sxyazi/yazi' os: $OS.linux package_manager: 'pacman' }
        ]
        --files [$"($linux_dir | path normalize)/**/*"]
        --dependencies ['oh-my-posh']
    )
}

def do-config []: nothing -> bool {
    mut ret = true
    let linux_dir: directory = work-dir $ID | get $SCOPE.linux
    let target_dir: directory = config-dir -m yazi
    let target_autoload_dir: directory = $nu.user-autoload-dirs.0

    log $MESSAGE.io_info_install_config
    for f in (glob $"($linux_dir)/*.toml") {
        let target_config_path: path = $target_dir | path join ($f | path basename)
        $ret = $ret and (cp-link -f $f $target_config_path)
    }

    log $MESSAGE.env_ok_nu_cmds
    let source_command_path: path = [$linux_dir nushell] | path join 'commands.nu'
    let target_command_path: path = $target_autoload_dir | path join $"commands-($ID).nu"
    $ret = $ret and (cp-link -f $source_command_path $target_command_path)

    log ($MESSAGE.pkg_info_install | template { what: "theme/plugins" })
    let installed_plugins = ya pkg list
    for p in (get-plugins) {
        if ($installed_plugins | str contains $p.name) { continue }
        $ret = $ret and (if (has-connection) { ya pkg add $p.name | complete | log; true } else { false })
        $ret = $ret and (if $env.LAST_EXIT_CODE == 0 {
            update-init ($p.name | split row '/').1 $p.body
        } else {
            false
        })
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
