#Requires -RunAsAdministrator
# Run in the new Windows VM after setup; close the apps being removed first.
$ErrorActionPreference = 'Stop'

# An explicit list keeps Windows servicing, security, Store, Edge/WebView2,
# media codecs and DRM components intact. Missing apps are simply skipped.
$apps = @(
    'Clipchamp.Clipchamp'
    'Microsoft.BingNews'
    'Microsoft.BingWeather'
    'Microsoft.Copilot'
    'Microsoft.GamingApp'
    'Microsoft.MicrosoftOfficeHub'
    'Microsoft.MicrosoftSolitaireCollection'
    'Microsoft.OutlookForWindows'
    'Microsoft.PowerAutomateDesktop'
    'Microsoft.Todos'
    'Microsoft.YourPhone'
    'MicrosoftTeams'
    'MSTeams'
)

Get-AppxProvisionedPackage -Online |
    Where-Object { $_.DisplayName -in $apps } |
    ForEach-Object {
        Write-Host "Removing provisioned app: $($_.DisplayName)"
        Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName | Out-Null
    }

Get-AppxPackage -AllUsers |
    Where-Object { $_.Name -in $apps } |
    ForEach-Object {
        Write-Host "Removing installed app: $($_.Name)"
        Remove-AppxPackage -AllUsers -Package $_.PackageFullName
    }

Write-Host 'Cleanup complete. Restart Windows, update your browser, and test NOW playback.'
