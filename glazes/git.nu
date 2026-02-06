use ../scripts/config.nu [SCOPE OS HIGHEST_PRIORITY]
use ../scripts/glaze.nu *
use ../scripts/messages.nu *
use ../scripts/libs/log.nu *
use ../scripts/libs/system.nu *
use ../scripts/libs/strings.nu *
use ../scripts/libs/fs.nu *
use ../scripts/libs/net.nu ['bitwarden get']

const ID = path self | path parse | get stem

# ============================================================================
#                        PRIVATE CUSTOMIZABLE COMMANDS
# ============================================================================

def get-manifest []: nothing -> record {
    let common_dir: directory = work-dir $ID | get $SCOPE.common

    (build-manifest
        $ID
        --category 'development'
        --description 'A free and open source distributed version control system, and tools.'
        --scope $SCOPE.common
        --priority $HIGHEST_PRIORITY
        --toppings [
            { name: 'git' url: 'https://git-scm.com/' os: $OS.linux package_manager: 'pacman' }
            { name: 'github-cli' url: 'https://cli.github.com/' os: $OS.linux package_manager: 'pacman' }
            { name: 'git-lfs' url: 'https://git-lfs.github.com' os: $OS.linux package_manager: 'pacman' }
            { name: 'gitleaks' url: 'https://gitleaks.io/' os: $OS.linux package_manager: 'pacman' }
            { name: 'git-delta' url: 'https://dandavison.github.io/delta/' os: $OS.linux package_manager: 'pacman' }
            { name: 'jujutsu' url: 'https://github.com/jj-vcs/jj' os: $OS.linux package_manager: 'pacman' }
            { name: 'onefetch' url: 'https://github.com/o2sh/onefetch' os: $OS.linux package_manager: 'pacman' }
            { name: 'hindsight' url: 'https://github.com/chaosprint/hindsight' os: $OS.linux package_manager: 'cargo' }
            { name: 'Git.Git' url: '{git.url}' os: $OS.windows package_manager: 'winget' }
            { name: 'GitHub.cli' url: '{github-cli.url}' os: $OS.windows package_manager: 'winget' }
            { name: 'GitHub.GitLFS' url: '{git-lfs.url}' os: $OS.windows package_manager: 'winget' }
            { name: 'Gitleaks.Gitleaks' url: '{gitleaks.url}' os: $OS.windows package_manager: 'winget' }
            { name: 'Git.GCM' url: 'https://github.com/git-ecosystem/git-credential-manager' os: $OS.windows package_manager: 'winget' }
            { name: 'dandavision.delta' url: '{git-delta.url}' os: $OS.windows package_manager: 'winget' }
            { name: 'jj-vcs.jj' url: '{jujutsu.url}' os: $OS.windows package_manager: 'winget' }
            { name: 'o2sh.onefetch' url: '{onefetch.url}' os: $OS.windows package_manager: 'winget' }
        ]
        --files [$"($common_dir | path normalize)/**/*"]
    )
}

def do-config []: nothing -> bool {
    mut ret = true
    let common_dir: directory = work-dir $ID | get $SCOPE.common
    let target_autoload_dir: directory = $nu.user-autoload-dirs.0
    let target_dir: directory = home-dir

    log -s git $MESSAGE.io_info_install_config
    let source_config_path: path = $common_dir | path join 'config'
    let target_config_path: path = $target_dir | path join '.gitconfig'
    if ($target_config_path | path exists) {
        log -s git ($MESSAGE.io_info_remove | template { target: $target_config_path })
        rm $target_config_path
    }
    log -s git ($MESSAGE.io_info_copy | template { source: $source_config_path target: $target_config_path })
    $ret = $ret and (cp -f $source_config_path $target_config_path ; $env.LAST_EXIT_CODE == 0)

    let source_attributes_path: path = $common_dir | path join 'gitattributes'
    let target_attributes_path: path = $target_dir | path join '.gitattributes'
    $ret = $ret and (cp-link -f $source_attributes_path $target_attributes_path)

    let source_message_path: path = $common_dir | path join 'gitmessage.txt'
    let target_message_path: path = $target_dir | path join '.gitmessage.txt'
    $ret = $ret and (cp-link -f $source_message_path $target_message_path)

    log -s git ($MESSAGE.pkg_info_install | template { what: 'hooks templates' })
    let source_hooks_dir: directory = $common_dir | path join 'hooks'
    let target_hooks_dir: directory = $target_dir | path join '.git-hooks'
    $ret = $ret and (cp-link -fr $source_hooks_dir $target_hooks_dir)

    log -s git $MESSAGE.env_ok_nu_cmds
    let source_command_path: path = [$common_dir nushell] | path join 'git.nu'
    let target_command_path: path = $target_autoload_dir | path join 'git.nu'
    $ret = $ret and (cp-link -f $source_command_path $target_command_path)

    mut pager = []

    if (is-installed gh) {
        log -s git ($MESSAGE.io_info_config | template { what: 'credential helpers for github' })
        let gh_path: string = (which gh | first | get path)
        git config set --global credential.https://github.com.helper $'($gh_path) auth git-credential'
        git config set --global credential.https://gist.github.com.helper $'($gh_path) auth git-credential'
    }

    if (is-linux) and (is-wsl) {
        log -s git ($MESSAGE.io_info_config | template { what: 'credential manager for WSL' })
        let gcm = glob '/mnt/c/Program Files*/Git/**/git-credential-manager.exe' | first
        if ($gcm | is-not-empty) {
            git config set --global credential.helper $"($gcm | str replace ' ' '\ ')"
        }
    } else if (is-windows) {
        log -s git ($MESSAGE.io_info_config | template { what: 'credential manager' })
        let gcm = glob 'c:/Program Files*/Git/**/git-credential-manager.exe' | first
        if ($gcm | is-not-empty) {
            git config set --global credential.helper $"($gcm | str replace ' ' '\ ')"
        }
    }

    log -s git ($MESSAGE.io_info_config | template { what: 'diffs settings' })
    if (is-installed diff-so-fancy) {
        $pager = [$"(which diff-so-fancy | first | get path)"]
        git config set --global interactive.diffFilter 'diff-so-fancy --patch'
    } else if (is-installed diff) {
        $pager = [$"(which diff | first | get path)"]
    }
    if ($pager | is-not-empty) {
        if (is-installed bat) {
            $pager = ($pager | append 'bat -p -l diff')
        } else if (is-installed less) {
            $pager = ($pager | append 'less --tabs=4 -RFX')
        } else if (is-installed cat) {
            $pager = ($pager | append 'cat')
        }
    }

    log -s git ($MESSAGE.io_info_config | template { what: 'global settings' })

    git config set --global commit.template $"'(home-dir | path join .gitmessage.txt)'"
    git config set --global core.editor $env.EDITOR

    if ($pager | is-not-empty) {
        git config set --global core.pager $"($pager | str join ((char space)(char pipe)(char space)))"
    }

    git config set --global core.excludesFile $"'(home-dir | path join .gitignore)'"
    git config set --global core.attributesFile $"'(home-dir | path join .gitattributes)'"

    if (is-installed hevi) {
        git config set --global diff.bin.textconv 'hevi'
    } else if (is-installed hexdump) {
        git config set --global diff.bin.textconv 'hexdump -v -C'
    }

    if (is-installed gpg) {
        git config set --global gpg.program $"(which gpg | first | get path)"
    }

    log -s git ($MESSAGE.io_info_config | template { what: 'user data' })
    let response = bitwarden get 'Git Config'
    if $response.success {
        git config set --global user.email $"($response.data.fields | where name == email | get 0.value)"
        git config set --global user.name $"($response.data.fields | where name == name | get 0.value)"
        git config set --global user.signingKey $"($response.data.fields | where name == signingKey | get 0.value)"
    }

    log -s jj ($MESSAGE.io_info_config | template { what: 'user data' })
    if $response.success {
        jj config set --user user.email $"($response.data.fields | where name == email | get 0.value)"
        jj config set --user user.name $"($response.data.fields | where name == name | get 0.value)"
        jj config set --user user.signingKey $"($response.data.fields | where name == signingKey | get 0.value)"
    }

    log -s git ($MESSAGE.io_info_config | template { what: 'LFS support' })
    git lfs install | complete | log

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
