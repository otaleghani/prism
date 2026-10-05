param([string]$CleanupScript)
$ErrorActionPreference = 'Stop'

# Exercise selection and removal without requiring Windows or uninstalling apps.
$script:installed = @('Microsoft.Copilot', 'Microsoft.WindowsStore', 'Microsoft.HEVCVideoExtension')
$script:provisioned = @('MSTeams', 'Microsoft.Edge', 'Microsoft.SecHealthUI')
$script:removed = @()
function Get-AppxPackage {
    param([switch]$AllUsers)
    if (!$AllUsers) { throw 'Existing users must be included' }
    $script:installed | ForEach-Object { [pscustomobject]@{ Name = $_; PackageFullName = "$_-installed" } }
}
function Get-AppxProvisionedPackage {
    param([switch]$Online)
    if (!$Online) { throw 'Expected the running Windows installation' }
    $script:provisioned | ForEach-Object { [pscustomobject]@{ DisplayName = $_; PackageName = "$_-provisioned" } }
}
function Remove-AppxPackage {
    param([switch]$AllUsers, [string]$Package)
    if (!$AllUsers) { throw 'Removal must include existing users' }
    $script:removed += $Package
}
function Remove-AppxProvisionedPackage {
    param([switch]$Online, [string]$PackageName)
    if (!$Online) { throw 'Expected the running Windows installation' }
    $script:removed += $PackageName
}

$source = Get-Content -Raw $CleanupScript
# Only the administrator requirement is omitted for this isolated Linux check.
$cleanup = [scriptblock]::Create(($source -replace '(?m)^#Requires -RunAsAdministrator\r?$', ''))
& $cleanup
if (($script:removed -join ',') -ne 'MSTeams-provisioned,Microsoft.Copilot-installed') {
    throw "Unexpected removal selection: $script:removed"
}

$script:installed = @()
$script:provisioned = @()
$script:removed = @()
& $cleanup
if ($script:removed.Count -ne 0) { throw 'An empty installation should need no changes' }
Write-Host 'Cleanup selection checks passed.'
