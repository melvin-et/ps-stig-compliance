<#
.SYNOPSIS
    This PowerShell script ensures that the password history is configured to 24 passwords remembered.
.NOTES
    Author          : Melvin E.
    LinkedIn       : 
    GitHub          : github.com/melvin-et
    Date Created    : 2025-06-25
    Last Modified   : 2025-06-25
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-AC-000020
.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 
.USAGE
    This script configures the password history policy to remember 24 passwords using secedit.
    Must be run with administrative privileges.
    Example syntax:
    PS C:\> .\STIG-ID-WN10-AC-000020.ps1 
#>

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script requires administrative privileges." -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
    exit 1
}

# Define temporary file paths
$exportPath = "$env:TEMP\secpol.cfg"
$importPath = "$env:TEMP\secpol_modified.cfg"
$logPath = "$env:TEMP\secpol_log.txt"

try {
    # Export current security policy
    Write-Host "Exporting current security policy..." -ForegroundColor Cyan
    $exportResult = secedit /export /cfg $exportPath /quiet
    
    if (Test-Path $exportPath) {
        # Read the exported policy
        $securityPolicy = Get-Content $exportPath -Raw
        
        # Check current password history value
        if ($securityPolicy -match 'PasswordHistorySize\s*=\s*(\d+)') {
            $currentValue = $matches[1]
            Write-Host "Current password history value: $currentValue" -ForegroundColor Yellow
        } else {
            Write-Host "Password history setting not found. Will add it." -ForegroundColor Yellow
            $currentValue = "Not configured"
        }
        
        # Update or add the password history setting
        if ($securityPolicy -match 'PasswordHistorySize\s*=\s*\d+') {
            # Replace existing value
            $securityPolicy = $securityPolicy -replace 'PasswordHistorySize\s*=\s*\d+', 'PasswordHistorySize = 24'
        } else {
            # Add the setting if it doesn't exist
            if ($securityPolicy -match '\[System Access\]') {
                $securityPolicy = $securityPolicy -replace '(\[System Access\][\r\n]+)', "`$1PasswordHistorySize = 24`r`n"
            } else {
                # Add System Access section if it doesn't exist
                $securityPolicy += "`r`n[System Access]`r`nPasswordHistorySize = 24`r`n"
            }
        }
        
        # Save the modified policy
        $securityPolicy | Out-File $importPath -Encoding Unicode
        
        # Import the modified security policy
        Write-Host "Applying new security policy..." -ForegroundColor Cyan
        $importResult = secedit /configure /db secedit.sdb /cfg $importPath /log $logPath /quiet
        
        # Verify the change
        Write-Host "Verifying the change..." -ForegroundColor Cyan
        Remove-Item $exportPath -Force -ErrorAction SilentlyContinue
        secedit /export /cfg $exportPath /quiet
        
        $verifyPolicy = Get-Content $exportPath -Raw
        if ($verifyPolicy -match 'PasswordHistorySize\s*=\s*24') {
            Write-Host "SUCCESS: Password history has been set to 24 passwords remembered per STIG ID: WN10-AC-000020" -ForegroundColor Green
            if ($currentValue -ne "Not configured") {
                Write-Host "Previous value was: $currentValue" -ForegroundColor Yellow
            }
        } else {
            Write-Host "ERROR: Failed to verify the policy change." -ForegroundColor Red
            exit 1
        }
        
    } else {
        Write-Host "ERROR: Failed to export security policy." -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "ERROR: An error occurred while configuring the password history policy. Error: $_" -ForegroundColor Red
    exit 1
} finally {
    # Clean up temporary files
    Remove-Item $exportPath -Force -ErrorAction SilentlyContinue
    Remove-Item $importPath -Force -ErrorAction SilentlyContinue
    Remove-Item $logPath -Force -ErrorAction SilentlyContinue
    Remove-Item "secedit.sdb" -Force -ErrorAction SilentlyContinue
}

# Display Group Policy equivalent
Write-Host "`nGroup Policy Equivalent:" -ForegroundColor Cyan
Write-Host "Computer Configuration >> Windows Settings >> Security Settings >> Account Policies >> Password Policy >>" -ForegroundColor Gray
Write-Host '"Enforce password history" = "24 passwords remembered"' -ForegroundColor Gray

# Security note
Write-Host "`nSecurity Note:" -ForegroundColor Yellow
Write-Host "This setting prevents users from recycling the same passwords, enhancing security by" -ForegroundColor Gray
Write-Host "ensuring password uniqueness over time. DoD requires 24 passwords to be remembered." -ForegroundColor Gray

# Additional information
Write-Host "`nNote: This change takes effect immediately for new password changes." -ForegroundColor Cyan
Write-Host "Users will not be able to reuse any of their last 24 passwords." -ForegroundColor Gray
