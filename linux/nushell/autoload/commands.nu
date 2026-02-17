# Prints out a structured version of system's `os-release` file.
def os-release [] {
    let file_path: path = '/etc/os-release'
    if ($file_path | path exists) {
        open $file_path | parse "{key}={value}"
    }
}

# Cleans platform's trash directory (used by `rm -t`).
def "clean trash" [] {
    let trash_path: path = if XDG_DATA_HOME in $env {
        $env.XDG_DATA_HOME | path join Trash
    } else {
        [$env.HOME .local share] | path join Trash
    }

    if ($trash_path | path exists) {
        let paths: list<path> = [
            ([$trash_path files] | path join '*')
            ([$trash_path info] | path join '*')
        ]
        for p in $paths {
            print -n $"cleaning ($p) ... "
            try {
                glob $p | each {rm -pr $in}
                print 'done'
            } catch {|err|
                print $"error: ($err.msg)"
            }
        }
    }
}
