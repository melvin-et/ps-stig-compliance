<#
.SYNOPSIS
    This PowerShell script ensures that users must be prompted for a password on resume from sleep (on battery).
.NOTES
    Author          : Melvin E.
    LinkedIn       : 
    GitHub          : github.com/melvin-et
    Date Created    : 2025-06-25
    Last Modified   : 2025-06-25
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-CC-000145
.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 
.USAGE
    This script configures the DCSettingIndex registry value to require password on resume from sleep when on battery.
    Must be run with administrative privileges.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-CC-000145.ps1 
#>

# Define the registry path and value
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\0e796bdb-100d-47d6-a2d5-f7d2daa51f51"
$valueName = "DCSettingIndex"
$valueData = 1  # Require password on resume from sleep (on battery)

# Check if the registry path exists, if not create it
if (-not (Test-Path $registryPath)) {
    try {
        New-Item -Path $registryPath -Force | Out-Null
        Write-Host "Created registry path: $registryPath"
    } catch {
        Write-Host "ERROR: Failed to create registry path. Error: $_" -ForegroundColor Red
        Write-Host "Ensure you are running this script with administrative privileges." -ForegroundColor Yellow
        exit 1
    }
}

# Get current value if it exists
$currentValue = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue

# Set the DCSettingIndex value
try {
    Set-ItemProperty -Path $registryPath -Name $valueName -Value $valueData -Type DWord
    
    # Verify the change
    $newValue = Get-ItemProperty -Path $registryPath -Name $valueName
    
    if ($newValue.$valueName -eq $valueData) {
        Write-Host "SUCCESS: Registry value '$valueName' set to '$valueData' at '$registryPath'." -ForegroundColor Green
        Write-Host "Password will now be required on resume from sleep when on battery per STIG ID: WN10-CC-000145" -ForegroundColor Green
        
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
    Write-Host "Ensure you are running this script with administrative privileges." -ForegroundColor Yellow
    exit 1
}

# Optional: Display the Group Policy equivalent for reference
Write-Host "`nGroup Policy Equivalent:" -ForegroundColor Cyan
Write-Host "Computer Configuration >> Administrative Templates >> System >> Power Management >> Sleep Settings >>" -ForegroundColor Gray
Write-Host '"Require a password when a computer wakes (on battery)" = "Enabled"' -ForegroundColor Gray

# Note about the GUID
Write-Host "`nNote: The GUID '0e796bdb-100d-47d6-a2d5-f7d2daa51f51' represents the password requirement on wake setting." -ForegroundColor Gray
Write-Host "DCSettingIndex controls the setting when on battery (DC = Direct Current/Battery power)." -ForegroundColor Gray
