export HISTFILE="$HOME/.zhistory"
export HISTSIZE=10000
export SAVEHIST=10000

export COLORTERM="truecolor"
export GCC_COLORS="error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01"
export LS_COLORS="$(vivid generate one-dark)"

export EDITOR="helix"
export VISUAL="helix"

export MANPAGER='sh -c "col -bx | bat -l man -p"'
export MANROFFOPT="-c"

export LESS='--incsearch --mouse --wheel-lines=3 --use-color --wordwrap'

export BROWSER=

# locale
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_PAPER="en_US.UTF-8"
export LC_NAME="en_US.UTF-8"
export LC_ADDRESS="en_US.UTF-8"
export LC_TELEPHONE="en_US.UTF-8"
export LC_MEASUREMENT="en_US.UTF-8"
export LC_IDENTIFICATION="en_US.UTF-8"

# xdg
export XDG_CACHE_HOME="${XDG_CACHE_HOME:="$HOME/.cache"}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:="$HOME/.config"}"
export XDG_DATA_HOME="${XDG_DATA_HOME:="$HOME/.local/share"}"
export XDG_STATE_HOME="${XDG_STATE_HOME:="$HOME/.local/state"}"

# node/npm
export NODE_REPL_HISTORY=~/.node_history
export NODE_REPL_HISTORY_SIZE='32768'
export NODE_REPL_MODE='sloppy'
export NPM_PATH="$XDG_CONFIG_HOME/node_modules"
export NPM_BIN="$XDG_CONFIG_HOME/node_modules/bin"
export NPM_CONFIG_PREFIX="$XDG_CONFIG_HOME/node_modules"
export PATH="$NPM_BIN:$PATH"

# gpg
# https://stackoverflow.com/a/42265848/96656
export GPG_TTY=$(tty)

export DOTFILES_ZSH_INSTALLED=1

export PATH="$HOME/.local/bin:$PATH"
