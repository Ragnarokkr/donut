use ../scripts/config.nu [SCOPE OS HIGHEST_PRIORITY]
use ../scripts/glaze.nu *
use ../scripts/messages.nu *
use ../scripts/libs/log.nu *
use ../scripts/libs/system.nu *
use ../scripts/libs/fs.nu *

const ID = path self | path parse | get stem

# ============================================================================
#                        PRIVATE CUSTOMIZABLE COMMANDS
# ============================================================================

def get-manifest []: nothing -> record {
    let os_dir: directory = work-dir $ID | get (get-os)

    (build-manifest
        $ID
        --category 'system'
        --description 'A simple, secure, and modern encryption tool.'
        --scope $SCOPE.common
        --priority $HIGHEST_PRIORITY
        --files [$"($os_dir | path normalize)/**/*"]
    )
}

def do-config []: nothing -> bool {
    if (is-wsl) {
        # ! UNCOMMENT IF HAVE ISSUES RUNNING WAYLAND PROGRAMS
        # let linux_dir: directory = work-dir $ID | get $SCOPE.linux
        # let target_dir: directory = config-dir -m ([systemd user] | path join)
        # let as_root = system first-available doas sudo

        # Fix WSL issue as described in https://github.com/microsoft/wslg/issues/1032
        # Apply workaround from https://github.com/microsoft/wslg/issues/1032#issuecomment-2345292609
        # log (msg $MESSAGE.pkg_info_install {what: $"service to fix issue ('https://github.com/microsoft/wslg/issues/1032' | ansi link)"})
        # let source_service_path: path = [$linux_dir wsl-wayland-symlink.service] | path join
        # let target_service_path: path = [$target_dir wsl-wayland-symlink.service] | path join
        # if (cp-link -f $source_service_path $target_service_path) {
        #     log "activating service"
        #     do { ^$as_root systemctl --user daemon-reload }
        #     do { ^$as_root systemctl --user enable wsl-wayland-symlink.service }
        #     do { ^$as_root systemctl --user start wsl-wayland-symlink.service }
            true
        # } else {
        #     false
        # }
    } else if (is-windows) {
        let windows_dir: directory = work-dir $ID | get $SCOPE.windows
        let target_dir: directory = home-dir

        log $MESSAGE.io_info_install_config
        let source_config_file = $windows_dir | path join 'wslconfig'
        let target_config_file = $target_dir | path join '.wslconfig'
        cp-link -f $source_config_file $target_config_file

        # https://learn.microsoft.com/en-us/windows/security/operating-system-security/network-security/windows-firewall/hyper-v-firewall#configure-hyper-v-firewall-settings
        log "Configuring firewall to open outbound connections for WSL"
        let ps = first-available pwsh powershell
        let result = do -i { ^$ps -nol -nop -ex Bypass -c "Set-NetFirewallHyperVVMSetting -Name '{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}' -DefaultOutboundAction Allow" } | complete
        $result | log
        $result.exit_code == 0
    }
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
