<#
.SYNOPSIS
    This PowerShell script ensures that Internet Explorer is disabled for Windows 10.
.NOTES
    Author          : Melvin E.
    LinkedIn       : 
    GitHub          : github.com/melvin-et
    Date Created    : 2025-06-25
    Last Modified   : 2025-06-25
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-CC-000391
.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 
.USAGE
    This script disables Internet Explorer 11 as a standalone browser on Windows 10.
    Must be run with administrative privileges.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-CC-000391.ps1 
#>

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script requires administrative privileges." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    exit 1
}

# Check Windows version
$osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
$osVersion = $osInfo.Version
$osCaption = $osInfo.Caption

Write-Host "Operating System: $osCaption" -ForegroundColor Cyan
Write-Host "Version: $osVersion" -ForegroundColor Cyan

# Define the registry path and value
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main"
$valueName = "NotifyDisableIEOptions"
$valueData = 2  # Never allow IE to be enabled

# Check if Internet Explorer is currently installed
$ieInstalled = Get-WindowsOptionalFeature -Online -FeatureName Internet-Explorer-Optional-amd64 -ErrorAction SilentlyContinue
if ($ieInstalled) {
    Write-Host "`nInternet Explorer installation status: $($ieInstalled.State)" -ForegroundColor Yellow
}

# Check if the registry path exists, if not create it
if (-not (Test-Path $registryPath)) {
    try {
        New-Item -Path $registryPath -Force | Out-Null
        Write-Host "`nCreated registry path: $registryPath"
    } catch {
        Write-Host "ERROR: Failed to create registry path. Error: $_" -ForegroundColor Red
        exit 1
    }
}

# Get current value if it exists
$currentValue = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue

# Set the registry value to disable IE11
try {
    Set-ItemProperty -Path $registryPath -Name $valueName -Value $valueData -Type DWord
    
    # Verify the change
    $newValue = Get-ItemProperty -Path $registryPath -Name $valueName
    
    if ($newValue.$valueName -eq $valueData) {
        Write-Host "`nSUCCESS: Registry value '$valueName' set to '$valueData' at '$registryPath'." -ForegroundColor Green
        Write-Host "Internet Explorer 11 is now disabled as a standalone browser per STIG ID: WN10-CC-000391" -ForegroundColor Green
        
        # Display previous value if it existed
        if ($currentValue) {
            Write-Host "Previous value was: $($currentValue.$valueName)" -ForegroundColor Yellow
        } else {
            Write-Host "Registry value did not exist previously and has been created." -ForegroundColor Yellow
        }
    } else {
        Write-Host "ERROR: Failed to verify the registry change." -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "ERROR: Failed to set registry value. Error: $_" -ForegroundColor Red
    exit 1
}

# Optional: Disable IE feature if it's enabled
Write-Host "`nChecking if Internet Explorer feature needs to be disabled..." -ForegroundColor Cyan
if ($ieInstalled -and $ieInstalled.State -eq "Enabled") {
    $response = Read-Host "Internet Explorer feature is currently enabled. Would you like to disable it? (Y/N)"
    if ($response -eq 'Y' -or $response -eq 'y') {
        try {
            Write-Host "Disabling Internet Explorer feature... (This may take a moment)" -ForegroundColor Yellow
            Disable-WindowsOptionalFeature -Online -FeatureName Internet-Explorer-Optional-amd64 -NoRestart -ErrorAction Stop
            Write-Host "Internet Explorer feature has been disabled." -ForegroundColor Green
            Write-Host "Note: A system restart is required to complete the removal." -ForegroundColor Yellow
        } catch {
            Write-Host "ERROR: Failed to disable Internet Explorer feature. Error: $_" -ForegroundColor Red
        }
    }
} elseif ($ieInstalled -and $ieInstalled.State -eq "Disabled") {
    Write-Host "Internet Explorer feature is already disabled." -ForegroundColor Green
}

# Display Group Policy equivalent
Write-Host "`nGroup Policy Equivalent:" -ForegroundColor Cyan
Write-Host "Computer Configuration >> Administrative Templates >> Windows Components >> Internet Explorer >>" -ForegroundColor Gray
Write-Host '"Disable Internet Explorer 11 as a standalone browser" = "Enabled" with option value "Never"' -ForegroundColor Gray

# Security note
Write-Host "`nSecurity Note:" -ForegroundColor Yellow
Write-Host "Internet Explorer 11 is no longer supported on Windows 10 semi-annual channel." -ForegroundColor Gray
Write-Host "Microsoft Edge is the recommended browser for Windows 10." -ForegroundColor Gray
Write-Host "For more information: https://learn.microsoft.com/en-us/lifecycle/faq/internet-explorer-microsoft-edge" -ForegroundColor Gray

# Additional checks
Write-Host "`nAdditional Information:" -ForegroundColor Cyan
$edgeInstalled = Get-AppxPackage -Name Microsoft.MicrosoftEdge -ErrorAction SilentlyContinue
if ($edgeInstalled) {
    Write-Host "Microsoft Edge is installed (recommended browser)." -ForegroundColor Green
} else {
    Write-Host "Warning: Microsoft Edge not found. Ensure a supported browser is available." -ForegroundColor Yellow
}
