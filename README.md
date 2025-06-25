<p align="center">
  <img src="https://github.com/user-attachments/assets/3609d24c-bd3b-4561-b88f-c978a82554df" alt="DISA STIG Logo" width="200"/>
</p>

<h1 align="center">🏢 DISA STIG Remediation PowerShell Scripts</h1>

<p align="center"><i>This repository contains PowerShell scripts designed to automate compliance with DISA STIG requirements for Windows systems.</i></p>

## Features
- Covers STIGs I've remediated (e.g., WN10, WS22)
- Tested on Windows 10 and Server 2022

### 📋 STIG Coverage

| DISA STIG ID | Issue |
|--------------|-------|
| [WN10-AU-000500](./STIGs/WN10-AU-000500.ps1) | Maximum size of the Application event log must be at least 32768 KB. |
| [WN10-CC-000185](./STIGs/STIG-ID-WN10-CC-000185.ps1) | The default autorun behavior must be configured to prevent autorun commands. |
| [WN10-AC-000020](./STIGs/WN10-AC-000020.ps1) | The password history must be configured to 24 passwords remembered. |
| [WN10-CC-000145](./STIGs/WN10-CC-000145.ps1) | Users must be prompted for a password on resume from sleep (on battery).  |
| [WN10-CC-000360](./STIGs/WN10-CC-000360.ps1) | The Windows Remote Management (WinRM) client must not use Digest authentication. |
| [WN10-CC-000391](./STIGs/WN10-CC-000391.ps1) | Internet Explorer must be disabled for Windows 10. |
| [WN10-SO-000100](./STIGs/WN10-SO-000100.ps1) | The Windows SMB client must be configured to always perform SMB packet signing. |

## Usage

Download or copy the script into a file.
Within PowerShell, **run the script**.


Example:
```powershell
.\STIGs\WN10-AU-000500.ps1
```
![image](https://github.com/user-attachments/assets/687b58e9-647b-45ef-9489-7ec10591ec4f)
