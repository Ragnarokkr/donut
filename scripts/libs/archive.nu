# Support library to interact with decompressors.

use ../messages.nu *
use ./system.nu [is-linux is-windows first-available]
use ./log.nu *

# Decompress an archive with a supported archiver.
#
# This is the order it will choose the destination directory:
# `--mktemp` -> `target` -> archive directory
export def decompress [
    archive: path   # archive path
    target?: string # target directory
    --mktemp (-t)   # decompress into a temporary directory
]: nothing -> record<success: bool, directory: path> {
    let archiver = (
        if (is-linux) {
            if ($archive | find -ir '\.(?:tar|tgz)\.?(?:zst|gz)?$' | is-not-empty) {
                first-available tar
            } else if ($archive | find -ir '\.(?:7z|zip|rar)$' | is-not-empty) {
                first-available NanaZipC 7z
            } else if ($archive | find -ir '\.(?:gz$)' | is-not-empty) {
                first-available gzip
            } else if ($archive | find -ir '\.(?:zst$)' | is-not-empty) {
                first-available zstd
            } else { error make { msg: $MESSAGE.arch_err_format } }
        } else if (is-windows) {
            first-available NanaZipC 7z
        }
    )

    if ($archiver | is-empty) { error make { msg: $MESSAGE.arch_err_tool_missing } }

    let target_dir = if $mktemp { mktemp -dt } else if ($target != null) { $target } else { $archive | path dirname }
    log -s decompress $MESSAGE.arch_info_decompress
    let result = match $archiver {
        $zip if ($zip == "NanaZipC") or ($zip == "7z") => { ^$archiver x $"($archive)" -o$"($target_dir)" -y }
        "tar" => { ^$archiver xvf $"($archive)" --directory=$"($target_dir)" }
        "gzip" => { ^$archiver -c -d -k $"($archive)" | save -fr $"($target_dir)" }
        "zstd" => { ^$archiver -c -d $"($archive)" | save -fr $"($target_dir)" }
    } | complete
    $result | log --scope decompress

    if ($result.exit_code != 0) {
        log -l $LOG_LEVEL.fail -s decompress (msg $MESSAGE.arch_err_decompress {error_code: ($result.exit_code | into string)})
        log -l $LOG_LEVEL.fail -s decompress (msg $MESSAGE.arch_warn_manual {what: $archive target: ($archive | path dirname)})
        { success: false, directory: $target_dir }
    } else {
        { success: true, directory: $target_dir }
    }
}
