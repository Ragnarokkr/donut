# Networking utilities

use ../messages.nu *
use ./log.nu *
use ./strings.nu *
use ./system.nu [is-linux is-windows get-os]

# Returns if current net connection is up and working.
#
# It keeps pinging the connection until it succeeds or the maximum
# number of retries is reached.
export def has-connection [
    --retries: int = 12         # max number of retries
    --interval: duration = 5sec # interval between retries
]: nothing -> bool {
    mut retries_count = 0

    loop {
        if $retries_count > $retries {
            log -l $LOG_LEVEL.fail $MESSAGE.net_err_down
            return false
        }

        if (is-linux) {
            ping -c 1 1.1.1.1 | ignore
        } else if (is-windows) {
            ping -n 1 1.1.1.1 | ignore
        }
        if $env.LAST_EXIT_CODE == 0 { return true }

        $retries_count += 1
        log -s net ($MESSAGE.net_info_wait | template { count: $"($retries_count)" })

        sleep $interval
    }

    false
}

# Download the latest release of an asset from GitHub
#
# The downloaded content is checked for integrity. If the check passes,
# the content is returned to the pipeline. It is up to the user to
# decide where to save it.
#
# Ref: https://docs.github.com/en/rest/releases/releases?apiVersion=2022-11-28#get-the-latest-release
export def "github get" [
    user: string          # user name
    repo: string          # repo name
    asset_pattern: string # pattern search regex
]: nothing -> oneof<any, nothing> {
    let response = http get $"https://api.github.com/repos/($user)/($repo)/releases/latest"
    let asset = $response | get assets | where {|asset| $asset.name | parse --regex $asset_pattern | is-not-empty } | first

    let check_integrity = {|content:binary, ref_hash:string|
        let hash = $ref_hash | parse '{version}:{digest}' | first
        match $hash.version? {
            'md5' => { ($content | hash md5) == $hash.digest }
            'sha256' => { ($content | hash sha256) == $hash.digest }
            _ => false
        }
    }

    if ($asset | is-not-empty) {
        log -s "net" ($MESSAGE.net_info_github_get | template { user: $user repo: $repo })
        if (has-connection) {
            let stream = http get $asset.browser_download_url

            log -s "net" $MESSAGE.net_info_digest
            let integrity = do $check_integrity $stream $asset.digest

            if $integrity {
                $stream
            } else {
                log -s "net" -l $LOG_LEVEL.error $MESSAGE.net_err_digest
                null
            }
        }
    } else {
        log -l $LOG_LEVEL.error -s "net" ($MESSAGE.net_err_github | template { user: $user repo: $repo })
        null
    }
}

# Download the latest archive from GitHub
#
# The downloaded content is returned to the pipeline. It is up to the user to
# decide where to save it.
export def "github get-archive" [
    user: string          # user name
    repo: string          # repo name
]: nothing -> oneof<any, nothing> {
    log -s "net" ($MESSAGE.net_info_github_get_archive | template { user: $user repo: $repo })
    if (has-connection) {
        try {
            http get $"https://github.com/($user)/($repo)/archive/refs/heads/master/master.zip"
        } catch {
            null
        }
    } else {
        null
    }
}

# Download the latest release of a project from SourceForge
#
# The downloaded content is checked for integrity. If the check passes,
# the content is returned to the pipeline. It is up to the user to
# decide where to save it.
#
# Ref: https://sourceforge.net/p/forge/documentation/Using%20the%20Release%20API/
export def "sourceforge get" [
    project: string # project name
    --os: string    # the target OS (default is current OS)
]: nothing -> oneof<any, nothing> {
    let response = http get $"https://sourceforge.net/projects/($project)/best_release.json"
    let release = $response.platform_releases? | get (if $os == null { os } else { $os })

    let check_integrity = {|stream: binary, digest: string|
        ($stream | hash md5) == $digest
    }

    if ($release | is-not-empty) {
        log -s "net" ($MESSAGE.net_info_sourceforge_get | template { project: $project })
        if (has-connection) {
            let stream = http get $release.url

            log -s "net" $MESSAGE.net_info_digest
            let integrity = do $check_integrity $stream $release.md5sum

            if $integrity {
                $stream
            } else {
                log -s "net" -l $LOG_LEVEL.error $MESSAGE.net_err_digest
                null
            }
        }
    } else {
        log -l $LOG_LEVEL.error -s "net" ($MESSAGE.net_err_sourceforge | template { project: $project })
        null
    }
}

# Retrieves an item from the Bitwarden's Vault
export def "bitwarden get" [
    item: string # item to retrieve
]: nothing -> record {
    mut ret = true

    # Checks the connection and current Vault status
    let response: oneof<record, nothing> = if (has-connection) { do { bw status --response } | from json }
    $ret = $ret and (match $response {
        null => { log -l $LOG_LEVEL.error $MESSAGE.net_err_down; false }

        { success: false data: _ } => {
            log -l $LOG_LEVEL.error ($MESSAGE.net_err_bw_connect | template { message: $response.message })
            false
        }

        { success: true data: $data } => {
            if $data.status? == "unauthenticated" {
                if (has-connection) {
                    log -l $LOG_LEVEL.security $MESSAGE.ui_info_bw_pass
                    let result = do -i { bw login } | complete
                    $result.exit_code == 0
                } else { false }
            } else { true }
        }
    })
    if not $ret { return { success: false } }

    # Checks connection and retrieves the item
    log -l $LOG_LEVEL.security $MESSAGE.ui_info_bw_pass
    let response: oneof<record, nothing> = if (has-connection) { do { bw get item $item --response } | from json }
    if $response == null {
        log -l $LOG_LEVEL.error $MESSAGE.net_err_down
        { success: false }
    } else {
        $response
    }
}
