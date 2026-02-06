# Main configuration file.
#
# All global costants and values are defined in this file to be used by
# the main script and all auxiliary scripts/libraries.

# ----------------------------------------------------------------------------
# --------------------------  APPLICATION MANIFEST  --------------------------
# ----------------------------------------------------------------------------

export const MANIFEST = {
    name: 'Dotfiles-Nushell Tracker'
    description: 'Track dotfiles. Glaze Nushell. Customize freely.'
}

# ----------------------------------------------------------------------------
# ---------------------------------  STATES  ---------------------------------
# ----------------------------------------------------------------------------

export const STATE = {
    initial: 'initial'
    preinstall: 'preinstall'
    preconfig: 'preconfig'
    first_restart: 'first_restart'
    install: 'install'
    config: 'config'
    done: 'done'
}

# ----------------------------------------------------------------------------
# ----------------------------------  DATA  ----------------------------------
# ----------------------------------------------------------------------------

export const HIGHEST_PRIORITY: int = 1
export const LOWEST_PRIORITY: int = 99
export const DATETIME_RESET = '1-1-1900' | format date '%F %T'
export const OS = {
    linux : 'linux'
    windows: 'windows'
}

# ----------------------------------------------------------------------------
# ------------------------------  DIRECTORIES  -------------------------------
# ----------------------------------------------------------------------------

export const DONUT_DIR = path self . | path dirname
export const GLAZES_DIR = 'glazes'
export const SCRIPTS_DIR = 'scripts'
export const SQL_DIR = $SCRIPTS_DIR | path join 'sql'
export const DEFAULT_COMMON_DIR = 'common'
export const DEFAULT_LINUX_DIR = $OS.linux
export const DEFAULT_WINDOWS_DIR = $OS.windows
export const DEFAULT_WINDOWS_USER_BIN_DIR = 'UserApp'

# ----------------------------------------------------------------------------
# ---------------------------------  PATHS  ----------------------------------
# ----------------------------------------------------------------------------

export const DATABASE_PATH: path = 'donut.db'
export const GLAZE_TEMPLATE_PATH: path = [$SCRIPTS_DIR glaze.tmpl.nu] | path join

# ----------------------------------------------------------------------------
# --------------------------------  ACTIONS  ---------------------------------
# ----------------------------------------------------------------------------

export const ACTION = {
    install: 0
    config: 1
}

# ----------------------------------------------------------------------------
# ---------------------------------  SCOPES  ---------------------------------
# ----------------------------------------------------------------------------

export const SCOPE = {
    common: 'common'
    linux: 'linux'
    windows: 'windows'
    disabled: 'disabled'
}

# ----------------------------------------------------------------------------
# ---------------------------------  HOOKS  ----------------------------------
# ----------------------------------------------------------------------------

export const HOOK = {
    preinstall: 'preinstall'
    install: 'install'
}
