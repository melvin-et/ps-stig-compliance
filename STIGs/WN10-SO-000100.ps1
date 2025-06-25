<#
.SYNOPSIS
    This PowerShell script ensures that the Windows SMB client is configured to always perform SMB packet signing.
.NOTES
    Author          : Melvin E.
    LinkedIn       : 
    GitHub          : github.com/melvin-et
    Date Created    : 2025-06-25
    Last Modified   : 2025-06-25
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-SO-000100
.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 
.USAGE
    This script configures the RequireSecuritySignature registry value to enable SMB packet signing for the SMB client.
    Must be run with administrative privileges.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-SO-000100.ps1 
#>

# Define the registry path and value
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"
$valueName = "RequireSecuritySignature"
$valueData = 1  # Always perform SMB packet signing

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

# Set the RequireSecuritySignature value
try {
    Set-ItemProperty -Path $registryPath -Name $valueName -Value $valueData -Type DWord
    
    # Verify the change
    $newValue = Get-ItemProperty -Path $registryPath -Name $valueName
    
    if ($newValue.$valueName -eq $valueData) {
        Write-Host "SUCCESS: Registry value '$valueName' set to '$valueData' at '$registryPath'." -ForegroundColor Green
        Write-Host "SMB client will now always perform packet signing per STIG ID: WN10-SO-000100" -ForegroundColor Green
        
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
Write-Host "Computer Configuration >> Windows Settings >> Security Settings >> Local Policies >> Security Options >>" -ForegroundColor Gray
Write-Host '"Microsoft network client: Digitally sign communications (always)" = "Enabled"' -ForegroundColor Gray

# Security note
Write-Host "`nSecurity Note:" -ForegroundColor Yellow
Write-Host "SMB packet signing helps prevent man-in-the-middle attacks by digitally signing all SMB packets." -ForegroundColor Gray
Write-Host "This ensures the integrity and authenticity of SMB communications." -ForegroundColor Gray

# Check related SMB signing settings
Write-Host "`nRelated SMB Signing Settings:" -ForegroundColor Cyan
$enableSecuritySignature = Get-ItemProperty -Path $registryPath -Name "EnableSecuritySignature" -ErrorAction SilentlyContinue
if ($enableSecuritySignature) {
    Write-Host "EnableSecuritySignature (if server agrees): $($enableSecuritySignature.EnableSecuritySignature)" -ForegroundColor Gray
} else {
    Write-Host "EnableSecuritySignature: Not configured" -ForegroundColor Gray
}

# Check if LanmanWorkstation service is running
$workstationService = Get-Service -Name LanmanWorkstation -ErrorAction SilentlyContinue
if ($workstationService) {
    Write-Host "`nLanmanWorkstation Service Status: $($workstationService.Status)" -ForegroundColor Cyan
    if ($workstationService.Status -eq "Running") {
        Write-Host "Note: A system restart may be required for changes to take full effect." -ForegroundColor Yellow
    }
} else {
    Write-Host "`nLanmanWorkstation Service not found on this system." -ForegroundColor Gray
}
