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


## Usage

Download or copy the script into a file.
Within PowerShell, **run the script**.


Example:
```powershell
.\STIGs\WN10-AU-000500.ps1
