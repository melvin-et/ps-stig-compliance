<#
.SYNOPSIS
    This PowerShell script ensures that the Windows Remote Management (WinRM) client does not use Digest authentication.
.NOTES
    Author          : Melvin E.
    LinkedIn       : 
    GitHub          : github.com/melvin-et
    Date Created    : 2025-06-25
    Last Modified   : 2025-06-25
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-CC-000360
.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 
.USAGE
    This script configures the AllowDigest registry value to disable Digest authentication for WinRM client.
    Must be run with administrative privileges.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-CC-000360.ps1 
#>

# Define the registry path and value
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client"
$valueName = "AllowDigest"
$valueData = 0  # Disable Digest authentication

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

# Set the AllowDigest value
try {
    Set-ItemProperty -Path $registryPath -Name $valueName -Value $valueData -Type DWord
    
    # Verify the change
    $newValue = Get-ItemProperty -Path $registryPath -Name $valueName
    
    if ($newValue.$valueName -eq $valueData) {
        Write-Host "SUCCESS: Registry value '$valueName' set to '$valueData' at '$registryPath'." -ForegroundColor Green
        Write-Host "WinRM client Digest authentication is now disabled per STIG ID: WN10-CC-000360" -ForegroundColor Green
        
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
Write-Host "Computer Configuration >> Administrative Templates >> Windows Components >> Windows Remote Management (WinRM) >>" -ForegroundColor Gray
Write-Host 'WinRM Client >> "Disallow Digest authentication" = "Enabled"' -ForegroundColor Gray

# Security note
Write-Host "`nSecurity Note:" -ForegroundColor Yellow
Write-Host "Digest authentication is vulnerable to man-in-the-middle attacks." -ForegroundColor Gray
Write-Host "This setting ensures WinRM client uses more secure authentication methods." -ForegroundColor Gray

# Check if WinRM service is running
$winrmService = Get-Service -Name WinRM -ErrorAction SilentlyContinue
if ($winrmService) {
    Write-Host "`nWinRM Service Status: $($winrmService.Status)" -ForegroundColor Cyan
    if ($winrmService.Status -eq "Running") {
        Write-Host "Note: Changes will take effect for new WinRM connections." -ForegroundColor Gray
    }
} else {
    Write-Host "`nWinRM Service not found on this system." -ForegroundColor Gray
}
