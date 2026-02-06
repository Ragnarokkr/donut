# Provides file-system related commands.

use ../config.nu [
    DONUT_DIR
    DEFAULT_COMMON_DIR
    DEFAULT_LINUX_DIR
    DEFAULT_WINDOWS_DIR
    DEFAULT_WINDOWS_USER_BIN_DIR
    SCOPE
]
use ../messages.nu *
use ./log.nu *
use ./strings.nu *
use ./system.nu *

# Normalize a path from Windows-style to Unix-style
export def "path normalize" []: path -> path {
    $in | str replace -ar '\\?\\' '/'
}

# Return the repository's working directories
#
# If a directory is passed as parameter, it will be appended to each of the
# returned working paths.
export def work-dir [
    dir: path = "" # local directory
]: nothing -> record {
    {
        $SCOPE.common: ([$DONUT_DIR $DEFAULT_COMMON_DIR $dir] | where $it != "" | path join | path expand),
        $SCOPE.linux: ([$DONUT_DIR $DEFAULT_LINUX_DIR $dir] | where $it != "" | path join | path expand),
        $SCOPE.windows: ([$DONUT_DIR $DEFAULT_WINDOWS_DIR $dir] | where $it != "" | path join | path expand),
    }
}

# Return the user's home directory based on current OS.
#
# If a directory is passed as parameter, it will be appended to the resulting
# path. It uses `HOME` and `USERPROFILE` environmental variables to resolve paths.
export def home-dir [
    dir?: path = "" # custom directory
    --make (-m)     # make the directory if it does not exists
]: nothing -> string {
    let ret = if (is-linux) {
        [$env.HOME $dir] | where $it != "" | path join
    } else if (is-windows) {
        [$env.USERPROFILE $dir] | where $it != "" | path join
    }
    if $make { mkdir $ret }
    $ret
}

# Return the user's configuration directory based on current OS.
#
# If a directory is passed as parameter, it will be appended to the resulting
# path. It adheres to XDG Base Directory Specification on Linux (and Windows),
# and relies on `APPDATA` and `LOCALAPPDATA` on Windows.
export def config-dir [
    dir?: path = "" # custom directory
    --make (-m)     # make the directory if it does not exists
    --not-sync (-n) # use `LOCALAPPDATA` instead of `APPDATA` (**Windows**)
]: nothing -> string {
    let ret = if "XDG_CONFIG_HOME" in $env {
        [$env.XDG_CONFIG_HOME $dir] | where $it != "" | path join
    } else if (is-linux) {
        [$env.HOME .config $dir] | where $it != "" | path join
    } else if (is-windows) {
        if ($not_sync) {
            [$env.LOCALAPPDATA $dir]| where $it != "" | path join
        } else {
            [$env.APPDATA $dir]| where $it != "" | path join
        }
    }
    if $make { mkdir $ret }
    $ret
}

# Return the user's local bin directory according to the current OS.
#
# If a directory is passed as parameter, it will be appended to the resulting
# path. It adheres to XDG Base Directory Specification on Linux,
# and uses a custom `UserApp` directory in `$SystemDrive` on Windows.
export def local-bin-dir [
    dir?: path = "" # custom directory
    --make (-m)     # make the directory if it does not exists
]: nothing -> string {
    if (is-linux) {
        home-dir -m ([.local bin $dir] | where $it != "" | path join)
    } else if (is-windows) {
        let ret = [$env.SYSTEMDRIVE (char path_sep) $DEFAULT_WINDOWS_USER_BIN_DIR $dir] | where $it != "" | path join
        if $make { mkdir $ret }
        $ret
    }
}

# Cross-platform copy/link
#
# Copies or symlinks according to the current OS.
export def cp-link [
    target: string      # target (source) path
    link_name: string   # link name (destination) path
    --force (-f)        # overwrites the destination if it does exists
    --recursive (-r)    # recursive copy if source is a directory (**Windows**)
]: nothing -> bool {
    mut $ret = true
    let expanded_link_name = $link_name | path expand -n

    $ret = $ret and (if ($expanded_link_name | path exists -n) {
        if $force {
            log ($MESSAGE.io_info_remove | template { target: $expanded_link_name })
            match ($expanded_link_name | path type) {
                symlink => { rm -f $expanded_link_name; $env.LAST_EXIT_CODE == 0 }
                file => { rm -f $expanded_link_name; $env.LAST_EXIT_CODE == 0 }
                dir => { rm -fr $expanded_link_name; $env.LAST_EXIT_CODE == 0 }
                _ => { false }
            }
        } else {
            log -l $LOG_LEVEL.error ($MESSAGE.io_err_exists | template { target: $expanded_link_name })
            false
        }
    } else { true })

    if not $ret { return false }

    # Windows Sucks Tales™: Linux and Windows manage administrative privileges
    # differently, as do copying and linking.
    # On Linux, there is no need for administrative privileges to create a
    # symbolic link, while on Windows it can be accomplished by running the script
    # in a shell with administrative privileges or by enabling Developer Mode.
    if (is-linux) {
        log ($MESSAGE.io_info_symlink | template { source: $target target: $expanded_link_name })
        $ret = $ret and (try { ln -s $target $expanded_link_name; $env.LAST_EXIT_CODE == 0 } catch { false })
    } else if (is-windows) {
        # Windows Sucks Tales™: Obviously, on Windows it's impossible to make a simple
        # logical symlink without messing up system settings and other bullshit 😒
        if not (is-admin) {
            log ($MESSAGE.io_info_copy | template { source: $target target: $expanded_link_name })
            $ret = $ret and (try {
                if not $recursive { cp $target $expanded_link_name } else { cp -r $target $expanded_link_name }
                $env.LAST_EXIT_CODE == 0
            } catch { false })
        } else {
            log ($MESSAGE.io_info_symlink | template { source: $target target: $expanded_link_name })
            $ret = $ret and (try {
                if not $recursive { mklink $expanded_link_name $target } else { mklink /d $expanded_link_name $target }
                $env.LAST_EXIT_CODE == 0
            } catch { false })
        }
    }

    $ret
}
