# Application messages

use ./libs/log.nu [LOG_TYPE]

export const MESSAGE = {
    # System & Core
    sys_err_state: $"Wrong state transition \(($LOG_TYPE.source.ansi_open){from_state}(ansi reset) -> ($LOG_TYPE.target.ansi_open){to_state}(ansi reset))"
    sys_err_generic: $"($LOG_TYPE.error.ansi_open)Error: {message}(ansi reset)"
    sys_err_requirements: 'Missing requirements. If one or more of the following are missing, please fix them and retry:'
    sys_info_restart_pre: 'Please restart your terminal/system to make all changes effective, and run again this script.'
    sys_info_restart_main: 'Please restart your terminal/system to make all changes effective.'

    # Glaze Management
    glaze_ok_preinstall: $"($LOG_TYPE.success.ansi_open)Glazes for preinstall phase have been installed and configured.(ansi reset)"
    glaze_ok_install: $"($LOG_TYPE.success.ansi_open)Glazes for install phase have been installed and configured.(ansi reset)"
    glaze_ok_added: $"Glaze ($LOG_TYPE.source.ansi_open){name}($LOG_TYPE.source.ansi_close) has been added. Once configured, run command ($LOG_TYPE.command.ansi_open)db --update($LOG_TYPE.command.ansi_close) to update the database.(ansi reset)"
    glaze_ok_removed: $"Glaze ($LOG_TYPE.source.ansi_open){name}($LOG_TYPE.source.ansi_close) has been removed. Run command ($LOG_TYPE.command.ansi_open)db --update($LOG_TYPE.command.ansi_close) to update the database.(ansi reset)"
    glaze_err_preinstall: $"An error occurred while ($LOG_TYPE.error.ansi_open){action}(ansi reset) the glazes for preinstall phase."
    glaze_err_install: $"An error occurred while ($LOG_TYPE.error.ansi_open){action}(ansi reset) the glazes for install phase."
    glaze_err_manifest: $"Error: unable to read manifest from ($LOG_TYPE.source.ansi_open){glaze}(ansi reset). Skipping..."
    glaze_err_exists: $"Error: glaze with name ($LOG_TYPE.error.ansi_open){name}($LOG_TYPE.error.ansi_close) already exists.(ansi reset)(char newline)"
    glaze_err_not_exists: $"Error: glaze with name ($LOG_TYPE.error.ansi_open){name}($LOG_TYPE.error.ansi_close) does not exist.(ansi reset)(char newline)"
    glaze_info_generic: '{status} glazes...'
    glaze_info_detail: $"{status} ($LOG_TYPE.action.ansi_open){glaze}(ansi reset)..."
    glaze_info_dep_generic: '{status} dependencies...'
    glaze_info_dep_detail: $"{status} dependency ($LOG_TYPE.action.ansi_open){glaze}(ansi reset)..."

    # Database
    db_info_status: $'{status} database...'
    db_info_searching: 'Searching for available glazes...'
    db_info_found: $"Found ($LOG_TYPE.note.ansi_open) {total} (ansi reset) glazes..."
    db_info_stats: $"Added: ($LOG_TYPE.note.ansi_open) {added} (ansi reset) - Updated: ($LOG_TYPE.note.ansi_open) {updated} (ansi reset) - Removed: ($LOG_TYPE.note.ansi_open) {removed} (ansi reset)"
    db_err_not_found: 'Database not found...'
    db_err_dependency: $"Unknown dependency ($LOG_TYPE.error.ansi_open){glaze}(ansi reset) found. Skipping..."
    db_warn_security: $"($LOG_TYPE.warning.ansi_open)At this point the database may contains sensible environment data.($LOG_TYPE.warning.ansi_close) You can run the ($LOG_TYPE.command.ansi_open)db --security-clean($LOG_TYPE.command.ansi_close) command to remove this data.($LOG_TYPE.warning.ansi_close)"

    # Network
    net_info_wait: $"Waiting for connection ($LOG_TYPE.comment.ansi_open)\( {count} )(ansi reset)..."
    net_info_github_get: $"Downloading ($LOG_TYPE.source.ansi_open){user}/{repo}($LOG_TYPE.source.ansi_close) asset from GitHub(ansi reset)"
    net_info_sourceforge_get: $"Downloading ($LOG_TYPE.source.ansi_open){project}($LOG_TYPE.source.ansi_close) from Sourceforge(ansi reset)"
    net_info_download: $"Downloading ($LOG_TYPE.source.ansi_open){what}(ansi reset)"
    net_info_digest: 'Checking file integrity...'
    net_err_down: 'No internet connection'
    net_err_bw_connect: $"Unable to connect to the password manager: ($LOG_TYPE.error.ansi_open){message}(ansi reset)"
    net_err_bw_get: $"Item ($LOG_TYPE.error.ansi_open){item}($LOG_TYPE.error.ansi_close) not found in vault: \(($LOG_TYPE.error.ansi_open){message}($LOG_TYPE.error.ansi_close))(ansi reset)"
    net_err_github: $"Asset ($LOG_TYPE.error.ansi_open){user}/{repo}($LOG_TYPE.error.ansi_close) not found on GitHub(ansi reset)"
    net_err_sourceforge: $"Project ($LOG_TYPE.error.ansi_open){project}($LOG_TYPE.error.ansi_close) not found on Sourceforge(ansi reset)"
    net_err_download: $"Unable to download ($LOG_TYPE.error.ansi_open){what}(ansi reset)"
    net_err_digest: 'File integrity check failed. The file may be corrupted or infected'

    # IO & Filesystem
    io_info_copy: $"Copying ($LOG_TYPE.source.ansi_open){source}($LOG_TYPE.source.ansi_close) -> ($LOG_TYPE.target.ansi_open){target}($LOG_TYPE.target.ansi_close)(ansi reset)"
    io_info_symlink: $"Symlinking ($LOG_TYPE.source.ansi_open){source}($LOG_TYPE.source.ansi_close) -> ($LOG_TYPE.target.ansi_open){target}($LOG_TYPE.target.ansi_close)(ansi reset)"
    io_info_remove: $"Removing ($LOG_TYPE.target.ansi_open){target}($LOG_TYPE.target.ansi_close)(ansi reset)"
    io_info_install_config: 'Installing configuration files'
    io_info_config: $"Configuring ($LOG_TYPE.source.ansi_open){what}($LOG_TYPE.source.ansi_close)(ansi reset)"
    io_err_config: $"Unable to configure ($LOG_TYPE.error.ansi_open){what}($LOG_TYPE.error.ansi_close)(ansi reset)"
    io_err_exists: $"($LOG_TYPE.error.ansi_open){target}($LOG_TYPE.error.ansi_close) already exists, cannot overwrite. Maybe use ($LOG_TYPE.command.ansi_open)--force($LOG_TYPE.command.ansi_close) flag.(ansi reset)"

    # Packages & Installers
    pkg_info_install_via: $"Installing packages via ($LOG_TYPE.command.ansi_open){command}($LOG_TYPE.command.ansi_close)(ansi reset)"
    pkg_info_get_installer: 'Downloading the installer'
    pkg_info_run_installer: 'Running the installer'
    pkg_info_install: 'Installing {what}'
    pkg_err_manager: $"Unknown package manager ($LOG_TYPE.error.ansi_open){command}(ansi reset)"
    pkg_err_no_installer: 'Unable to find a valid installer'

    # Environment & Shell
    env_ok_nu_config: $"Installing ($LOG_TYPE.source.ansi_open)configuration files($LOG_TYPE.source.ansi_close) in nushell's user autoload(ansi reset)"
    env_ok_nu_cmds: $"Installing ($LOG_TYPE.source.ansi_open)custom commands($LOG_TYPE.source.ansi_close) in nushell's user autoload(ansi reset)"
    env_ok_nu_vars: $"Installing ($LOG_TYPE.source.ansi_open)environment variables($LOG_TYPE.source.ansi_close) in nushell(ansi reset)"
    env_err_save: $"Unable to save the environment changes."

    # Archive Operations
    arch_info_decompress: 'Decompressing archive'
    arch_err_format: 'Unknown archive format'
    arch_err_decompress: $"Unable to decompress archive [error code: ($LOG_TYPE.error.ansi_open){error_code}($LOG_TYPE.error.ansi_close)](ansi reset)"
    arch_err_tool_missing: 'No supported archiver found on the system'
    arch_warn_manual: $"It is required manual unpacking and installation of ($LOG_TYPE.warning.ansi_open){what}($LOG_TYPE.warning.ansi_open) in ($LOG_TYPE.target.ansi_open){target}($LOG_TYPE.target.ansi_close)(ansi reset)"

    # User Interation
    ui_info_press_key: 'When the process has finished, press a key to continue...'
    ui_info_bw_pass: $"($LOG_TYPE.comment.ansi_open)It will be required Bitwarden Master password...(ansi reset)"
}
