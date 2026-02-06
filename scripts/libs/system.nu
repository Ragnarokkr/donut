# System-wide utilities

# Check if current OS is a Linux distribution.
export def is-linux []: nothing -> bool { $nu.os-info.name == "linux" }

# Check if current OS is Windows.
export def is-windows []: nothing -> bool { $nu.os-info.name == "windows" }

# Check if Windows Subsystem for Linux is running
export def is-wsl []: nothing -> bool { $nu.os-info.name == "linux" and ($nu.os-info.kernel_version | find -ir '(microsoft|wsl)' | is-not-empty) }

# Check if an executable is installed and reachable from the PATH
export def is-installed [package: string]: nothing -> bool { which $package | is-not-empty }

# Return the current OS.
export def get-os []: nothing -> string { $nu.os-info.name }

# Return the first executable from the list that is installed and reachable
# from the PATH.
#
# The list is tested from left to right, so the order in which the commands are
# listed does matter.
export def first-available [
    ...commands: # commands to check for
]: nothing -> string {
    for cmd in $commands {
        if (is-installed $cmd) { return $cmd }
    }
    return ""
}
