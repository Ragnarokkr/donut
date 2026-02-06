<#
.SYNOPSIS
    Assign DNS servers to active Ethernet/Wireless adapters.

.DESCRIPTION
    This script loops through all active Ethernet/Wireless adapters
    and assign specified custom DNS addresses.

.NOTES
    Optional: BurntToast module for enhanced notifications.
    Installation of BurntToast: Install-Module -Name BurntToast

    The script requires administrative privileges to run.

.EXAMPLE
    # Set custom DNS servers directly
    PS> Set-CustomDNS.ps1 -DnsServers '192.168.1.1', '192.168.1.2'

.EXAMPLE
    # Prompt for a predefined DNS provider
    PS> Set-CustomDNS.ps1 -SelectDNSProvider

.EXAMPLE
    # Use default AdGuard DNS (Security+Ad Blocking DNS)
    PS> Set-CustomDNS.ps1

.LINK
    BurntToast repo: https://github.com/Windos/BurntToast
.LINK
    Free public DNS services: https://www.geckoandfly.com/27285/free-public-dns-servers/
#>
[CmdletBinding(DefaultParameterSetName='PredefinedDns')]
param(
    [Parameter(Mandatory=$false, ParameterSetName='CustomDns')]
    [string[]]$DnsServers,

    [Parameter(Mandatory=$false, ParameterSetName='PredefinedDns')]
    [switch]$SelectDNSProvider
)

# Define a hashtable of DNS providers and their servers
$DnsProviders = @{
    'AdGuard DNS (Family Safe)' = @('94.140.14.15', '94.140.15.16');
    'AdGuard DNS (Performance)' = @('94.140.14.140', '94.140.15.141');
    'AdGuard DNS (Security+Ad Blocking DNS)' = @('94.140.14.14', '94.140.15.15');
    'CleanBrowsing (Family Safe)' = @('185.228.168.168', '185.228.169.168');
    'Cloudflare (Performance)' = @('1.1.1.1', '1.0.0.1');
    'Cloudflare (Security+Family Safe)' = @('1.1.1.3', '1.0.0.3');
    'Cloudflare (Security)' = @('1.1.1.2', '1.0.0.2');
    'Comodo Secure DNS 2.0 (Security)' = @('8.26.56.26', '8.20.247.20');
    'Control D (Security+Ad Blocking DNS)' = @('76.76.2.2', '76.76.10.2');
    'Control D Family Friendly (Security+Family Safe)' = @('76.76.2.4', '76.76.10.4');
    'DNS For Family (Family Safe)' = @('94.130.180.225', '78.47.64.161');
    'DNSWatch (Performance)' = @('84.200.69.80', '84.200.70.40');
    'DYN Free Recursive DNS (Performance)' = @('216.146.35.35', '216.146.36.36');
    'GCore Publis DNS (Security+Performance)' = @('95.85.95.85', '2.56.220.2');
    'Google Public (Performance)' = @('8.8.8.8', '8.8.4.4');
    'OpenDNS FamilyShield (Family Safe)' = @('208.67.222.123', '208.67.220.123');
    'OpenDNS Home (Performance)' = @('208.67.222.222', '208.67.220.220');
    'Quad9 (Privacy + Security)' = @('9.9.9.9', '149.112.112.112');
    'SafeSurfer (Family)' = @('104.197.28.121', '104.155.237.225');
    'UltraDNS Public (Neustar DNS) (Family)' = @('156.154.70.3', '156.154.71.3');
    'Yandex DNS Basic' = @('77.88.8.8', '77.88.8.1');
    'Yandex DNS Family (Family Safe)' = @('77.88.8.7', '77.88.8.3');
    'Yandex DNS Safe (Security)' = @('77.88.8.88', '77.88.8.2');
}

$ResPath = Join-Path (Split-Path -Parent $PSCommandPath) "res"

# Determine the DNS servers to use
if ($SelectDNSProvider.IsPresent) {
    $sortedProviderNames = $DnsProviders.Keys | Sort-Object
    $choices = @()
    $hotkeyChar = [int][char]'A' # Start with ASCII value of 'A' for hotkeys
    $menuItems = @()

    # Add DNS provider choices with hotkeys and build menu items for vertical display
    for ($i = 0; $i -lt $sortedProviderNames.Count; $i++) {
        $providerName = $sortedProviderNames[$i]
        $hotkey = [char]$hotkeyChar
        $choices += New-Object System.Management.Automation.Host.ChoiceDescription "&${hotkey}. $providerName", "Set DNS to $providerName"
        $menuItems += "${hotkey}. $providerName"
        $hotkeyChar++
    }

    # Add a "Cancel" option as the last choice with its own hotkey
    $cancelChoiceIndex = $choices.Count
    $cancelHotkey = [char]$hotkeyChar # Assign next available char
    $choices += New-Object System.Management.Automation.Host.ChoiceDescription "&${cancelHotkey}. Cancel", "Do not set any predefined DNS servers."
    $menuItems += "${cancelHotkey}. Cancel"

    $caption = "Select a DNS Provider"
    $message = "Please choose a DNS provider from the list below:`n`n" + ($menuItems -join "`n") + "`n"

    # Find the index of the default choice (AdGuard Security+Ad Blocking DNS) in the sorted list
    $defaultProviderName = 'AdGuard DNS (Security+Ad Blocking DNS)'
    $defaultChoiceIndex = [array]::IndexOf($sortedProviderNames, $defaultProviderName)
    if ($defaultChoiceIndex -eq -1) {
        $defaultChoiceIndex = 0 # Fallback to first item if default not found
    }

    $result = $Host.UI.PromptForChoice($caption, $message, $choices, $defaultChoiceIndex)

    if ($result -ne $cancelChoiceIndex) { # If user did not select "Cancel" (using its assigned index)
        # The result index directly corresponds to the index in $sortedProviderNames
        $selectedProviderName = $sortedProviderNames[$result]
        $DnsServers = $DnsProviders[$selectedProviderName]
    } else {
        # User cancelled or chose the explicit "Cancel" option
        $DnsServers = $DnsProviders[$defaultProviderName]
        Write-Warning "DNS provider selection cancelled. Defaulting to '$defaultProviderName'."
    }
}
# If no DnsServers are provided and SelectDNSProvider was not explicitly used for prompting, default to AdGuard
elseif (-not $PSBoundParameters.ContainsKey('DnsServers')) {
    $DnsServers = $DnsProviders['AdGuard DNS (Security+Ad Blocking DNS)']
    Write-Verbose "No DNS servers specified or selected. Defaulting to 'AdGuard DNS (Security+Ad Blocking DNS)'."
}

# Import BurntToast module or define a dummy function if not available
Import-Module BurntToast -ErrorAction SilentlyContinue

if (-not (Get-Module -Name BurntToast -ErrorAction SilentlyContinue)) {
    Write-Warning "The BurntToast module is not installed. Notifications will not be displayed."
    # Define a dummy function to avoid errors if BurntToast is missing
    function New-BurntToastNotification {
        param(
            [string]$Text1,
            [string]$Text2
        )
        Write-Host "Notification: $Text1 - $Text2"
    }
}

# Ensure DNS servers are set before proceeding
if (-not $DnsServers) {
    Write-Error "No DNS servers were specified or selected. Exiting script."
    exit 1
}

# Get active Ethernet/Wireless adapters, skip virtual and loopback
$adapters = Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' -and $_.ConnectorPresent -eq $true }

foreach ($a in $adapters) {
    $iface = Get-NetIPConfiguration -InterfaceIndex $a.ifIndex
    # Ensure the interface has an IP address configuration before attempting to modify DNS
    if ($iface.IPv4Address -ne $null -or $iface.IPv6Address -ne $null) {
        try {
            # Set DNS to point at the selected or default DNS servers.
            Set-DnsClientServerAddress -InterfaceIndex $a.ifIndex -ServerAddresses $DnsServers -ErrorAction Stop
            Clear-DnsClientCache
            New-BurntToastNotification -AppLogo (Join-Path $ResPath "success.ico") -Text "Set DNS on interface $($a.Name) ($($a.ifIndex)):", "$($DnsServers -join ', ')"
        } catch {
            New-BurntToastNotification -AppLogo (Join-Path $ResPath "error.ico") -Text "Failed to set DNS on $($a.Name)", "$_"
            Write-Error "Failed to set DNS on $($a.Name): $_"
        }
    } else {
        Write-Verbose "Interface $($a.Name) ($($a.ifIndex)) has no IP address configuration, skipping."
    }
}
