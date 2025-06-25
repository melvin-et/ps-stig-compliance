<#
.SYNOPSIS
    This PowerShell script ensures that the default autorun behavior is configured to prevent autorun commands from executing.
.NOTES
    Author          : Melvin E.
    LinkedIn       : 
    GitHub          : github.com/melvin-et
    Date Created    : 2025-06-25
    Last Modified   : 2025-06-25
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-CC-000185
.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 
.USAGE
    This script configures the NoAutorun registry value to prevent autorun commands from executing.
    Must be run with administrative privileges.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-CC-000185.ps1 
#>

# Define the registry path and value
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
$valueName = "NoAutorun"
$valueData = 1  # Disable autorun commands

# Check if the registry path exists, if not create it
if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
    Write-Host "Created registry path: $registryPath"
}

# Get current value if it exists
$currentValue = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue

# Set the NoAutorun value
try {
    Set-ItemProperty -Path $registryPath -Name $valueName -Value $valueData -Type DWord
    
    # Verify the change
    $newValue = Get-ItemProperty -Path $registryPath -Name $valueName
    
    if ($newValue.$valueName -eq $valueData) {
        Write-Host "SUCCESS: Registry value '$valueName' set to '$valueData' at '$registryPath'." -ForegroundColor Green
        Write-Host "Autorun commands are now disabled per STIG ID: WN10-CC-000185" -ForegroundColor Green
        
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
Write-Host "Computer Configuration >> Administrative Templates >> Windows Components >> AutoPlay Policies >>" -ForegroundColor Gray
Write-Host '"Set the default behavior for AutoRun" = "Enabled: Do not execute any autorun commands"' -ForegroundColor Gray
