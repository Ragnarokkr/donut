# DoNuT Logging System
# Provides log levels, log colors, and logging functionalites.

use ./strings.nu *

export const LOG_TYPE = {
    action: { ansi_open: (ansi white_bold) ansi_close: ((ansi reset_bold)(ansi default)) }
    command: { ansi_open: (ansi xterm_darkslategray1) ansi_close: (ansi default) }
    comment: { ansi_open: ((ansi xterm_grey39)(ansi attr_italic)) ansi_close: ((ansi reset_italic)(ansi default)) }
    parameter: { ansi_open: (ansi blue) ansi_close: (ansi default) }
    scope: { ansi_open: (ansi xterm_lightskyblue1) ansi_close: (ansi default) }
    source: { ansi_open: (ansi light_green) ansi_close: (ansi default) }
    success: { ansi_open: (ansi green) ansi_close: (ansi default) }
    target: { ansi_open: (ansi xterm_sandybrown) ansi_close: (ansi default) }
    workspace: { ansi_open: (ansi cyan_bold) ansi_close: ((ansi reset_bold)(ansi default)) }
    error: { tag: 'ERROR' symbol: '' ansi_open: (ansi light_red) ansi_close: (ansi default) }
    fail: { tag: 'FAIL' symbol: '' ansi_open: (ansi red) ansi_close: (ansi default) }
    info: { tag: 'INFO' symbol: '' ansi_open: (ansi cyan) ansi_close: (ansi default) }
    install: { tag: 'INSTALL' symbol: '' ansi_open: (ansi xterm_aquamarine1a) ansi_close: (ansi default) }
    config: { tag: 'CONFIG' symbol: '' ansi_open: (ansi xterm_aquamarine1a) ansi_close: (ansi default) }
    note: { tag: 'NOTE' symbol: '' ansi_open: (ansi attr_reverse) ansi_close: (ansi reset_reverse) }
    security: { tag: 'SECURITY' symbol: '󰒃' ansi_open: (ansi light_red_reverse) ansi_close: ((ansi reset_reverse)(ansi default))}
    stderr: { tag: 'STDERR' ansi_open: ((ansi xterm_indianred1a)(ansi attr_italic)) ansi_close: ((ansi reset_italic)(ansi default)) }
    stdout: { tag: 'STDOUT' ansi_open: ((ansi white)(ansi attr_italic)) ansi_close: ((ansi reset_italic)(ansi default)) }
    exit: { tag: 'EXIT' ansi_open: ((ansi purple)(ansi attr_italic)) ansi_close: ((ansi reset_italic)(ansi default)) }
    user_input: { tag: 'INPUT' symbol: '⌨' ansi_open: (ansi cyan_reverse) ansi_close: ((ansi reset_reverse)(ansi default)) }
    warning: { tag: 'WARNING' symbol: '' ansi_open: (ansi yellow) ansi_close: (ansi default) }
}

export const LOG_LEVEL = {
    error: $LOG_TYPE.error
    exit: $LOG_TYPE.exit
    fail: $LOG_TYPE.fail
    info: $LOG_TYPE.info
    install: $LOG_TYPE.install
    config: $LOG_TYPE.config
    note: $LOG_TYPE.note
    security: $LOG_TYPE.security
    stderr: $LOG_TYPE.stderr
    stdout: $LOG_TYPE.stdout
    user_input: $LOG_TYPE.user_input
    warning: $LOG_TYPE.warning
}

# ============================  PRIVATE COMMANDS  ============================

def log-level [
    level: record
]: nothing -> string {
    let label_max_width: number = $LOG_LEVEL | items {|k,v| $v.tag} | str length | math max

    ($"($level.ansi_open) ($level.tag | fill -w $label_max_width -a right)"
        + (if 'symbol' in $level { $" ($level.symbol) " } else { ' ' })
        + $level.ansi_close)
}

def composed-scope [
    scope?: string
]: nothing -> string {
    if ($env.DONUT_WS | is-not-empty) and ($scope != null) {
        $" [($LOG_TYPE.workspace.ansi_open)($env.DONUT_WS | last)(ansi reset):($LOG_TYPE.scope.ansi_open)($scope)(ansi reset)] "
    } else if ($env.DONUT_WS | is-not-empty) {
        $" [($LOG_TYPE.workspace.ansi_open)($env.DONUT_WS | last)(ansi reset)] "
    } else if ($scope != null) {
        $" [($LOG_TYPE.scope.ansi_open)($scope)(ansi reset)] "
    } else { ' ' }
}

def log-record []: [record -> list<string>, nothing -> list<nothing>] {
    let input = $in
    mut messages = []

    const LOG_MESSAGE = "{output}: {message}"

    if ($input | describe | str contains "record") {
        if ($input.stderr? | is-not-empty) {
            $messages ++= [($input.stderr
            | lines
            | compact
            | each {|line| $LOG_MESSAGE | template { output: (log-level $LOG_LEVEL.stderr) message: $line }}
            )]
        }

        if ($input.stdout? | is-not-empty) {
            $messages ++= [($input.stdout
            | lines
            | compact
            | each {|line| $LOG_MESSAGE | template { output: (log-level $LOG_LEVEL.stdout) message: $line }}
            )]
        }

        if ("exit_code" in $input) {
            $messages ++= [($LOG_MESSAGE | template {
                output: (log-level $LOG_LEVEL.exit)
                message: $"External command finished with exit code: ($input.exit_code)"
            })]
        }

        if ("msg" in $input) {
            $messages ++= [($LOG_MESSAGE | template {
                output: (log-level $LOG_LEVEL.exit)
                message: $"An exception stopped the script: ($input.msg)"
            })]
        }
    }

    $messages | flatten
}

# ============================  PUBLIC COMMANDS  =============================

# Print out logging messages
#
# It accepts a single message as parameter, and/or both a `complete` output
# and `catch` output as input pipeline.
# Each message line begins with a timestamp and the current log level.
# If no log level is specified, it will be used `$LOG_LEVEL.info` as default.
export def --env main [
    message?: string # log message
    --log-level (-l): record = $LOG_LEVEL.info  # log level
    --scope (-s): string                        # current scope identifier
    --workspace (-w): string                    # set a new workspace
    --exit-workspace (-x)                       # exit from current workspace
]: [record -> nothing, nothing -> nothing] {
    if 'DONUT_WS' not-in $env {
        $env.DONUT_WS = []
    }

    if $workspace != null {
        $env.DONUT_WS = $env.DONUT_WS | append $workspace
        return null
    }

    if $exit_workspace {
        $env.DONUT_WS = $env.DONUT_WS | drop
        if ($env.DONUT_WS | is-empty) { hide DONUT_WS }
        return null
    }

    let input = $in | collect

    const LOG_MESSAGE = "{timestamp} {loglevel}{composedscope}{message}"

    if ($message | is-not-empty) {
        print -e ($LOG_MESSAGE | template {
            timestamp: (date now | format date "%Y-%m-%d %H:%M:%S")
            loglevel: (log-level $log_level)
            composedscope: (composed-scope $scope)
            message: $message
        })
    }

    for i in ($input | log-record) {
        print -e ($LOG_MESSAGE | template {
            timestamp: (date now | format date "%Y-%m-%d %H:%M:%S")
            loglevel: (log-level $log_level)
            composedscope: (composed-scope $scope)
            message: $i
        })
    }
}
