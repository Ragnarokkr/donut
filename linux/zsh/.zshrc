#!/usr/bin/env zsh

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# CHANGING DIRECTORIES
setopt AUTO_CD           # Go to folder path without using cd.
setopt AUTO_PUSHD        # Push the old directory onto the stack on cd.
setopt CHASE_LINKS       # Resolve symbolic links to their true values when changing directory.
setopt PUSHD_IGNORE_DUPS # Do not store duplicates in the stack.
setopt PUSHD_SILENT      # Do not print the directory stack after pushd or popd.

# CORRECTION AND GLOBBING
setopt BAD_PATTERN
setopt CDABLE_VARS   # Change directory to a path stored in a variable.
setopt EXTENDED_GLOB # Use extended globbing syntax.
setopt GLOB
setopt MARK_DIRS
setopt NULL_GLOB
unsetopt BEEP

# HISTORY
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY       # Write the history file in the ':start:elapsed;command' format.
setopt SHARE_HISTORY          # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS       # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS   # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS      # Do not display a previously found event.
setopt HIST_IGNORE_SPACE      # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS      # Do not write a duplicate event to the history file.
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks from each command line.
setopt HIST_VERIFY            # Do not execute immediately upon history expansion.

# I/O
setopt ALIASES
setopt CORRECT # Spelling correction

# JOB CONTROL
setopt CHECK_JOBS # Report the status of background and suspended jobs before exiting a shell with job control
setopt NOTIFY

bindkey -e

# make less more friendly for non-text input files, see lesspipe(1)
[[ -x /usr/bin/lesspipe ]] && export LESSOPEN="|lesspipe %s"

# Sources .dotfiles
typeset dotfile=""
for dotfile in $HOME/.{zcompletions,zaliases,zextras,zkeybindings,zlogin,extra}; do
    [[ -f $dotfile ]] && source $dotfile
done

# Autoload custom functions
fpath=($XDG_CONFIG_HOME/zsh/functions $fpath)
autoload -Uz $fpath[1]/*(.:t)

# Autoload custom plugins
fpath=($XDG_CONFIG_HOME/zsh/plugins $fpath)
autoload -Uz $fpath[1]/*(.:t)

autoload -Uz compinit
compinit
_comp_options+=(globdots) # With hidden files
