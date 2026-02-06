# Define source and destination paths.
# The default PowerShell profile path is usually $PROFILE.CurrentUserAllHosts
$sourceProfile = Join-Path $PSScriptRoot 'profile.ps1' -Resolve
$destinationProfileDir = Split-Path -Path $PROFILE.CurrentUserAllHosts -Parent
$destinationProfile = $PROFILE.CurrentUserAllHosts

# Check if the source file exists before attempting to copy.
if (-not (Test-Path -Path $sourceProfile -PathType Leaf)) {
    Write-Error "Source PowerShell profile not found at '$sourceProfile'. Skipping PowerShell profile configuration."
    return
}

# Ensure the destination directory exists.
if (-not (Test-Path -Path $destinationProfileDir -PathType Container)) {
    try {
        New-Item -ItemType Directory -Path $destinationProfileDir -ErrorAction Stop | Out-Null
    }
    catch {
        Write-Error "Failed to create PowerShell profile directory '$destinationProfileDir': $($_.Exception.Message)"
        return
    }
}

try {
    # Use -Force to overwrite an existing profile in the destination.
    Copy-Item -Path $sourceProfile -Destination $destinationProfile -Force -ErrorAction Stop
}
catch {
    Write-Error "Failed to copy PowerShell profile: $($_.Exception.Message)"
}
