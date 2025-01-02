<#
.SYNOPSIS
    Simulates MITRE ATT&CK T1564.001 (Hidden Files and Directories) and performs local Threat Hunting.

.DESCRIPTION
    1. Creates a payload file in the Downloads directory.
    2. Modifies file attributes to 'Hidden' using attrib.exe.
    3. Queries Sysmon logs (EIDs 1, 11, 15) to hunt for the execution and file creation artifacts.
    4. Cleans up the environment.
#>

Write-Host "--- Starting Attack Simulation: T1564.001 (Hidden Files) ---" -ForegroundColor Yellow

# =================================================================
# 1. Preparation Phase
# =================================================================
$FilePath = "$env:USERPROFILE\Downloads\T1564.001.txt"

Write-Host "[+] Creating dummy payload at $FilePath" -ForegroundColor Cyan
"system_Attrib_T1564.001" | Out-File -FilePath $FilePath -Encoding ASCII -Force

# Verify creation
if (Test-Path $FilePath) {
    Write-Host "[+] Initial Attributes:"
    Get-Item $FilePath -Force | Select-Object FullName, Attributes | Format-Table
}

# =================================================================
# 2. Execution Phase (Defense Evasion)
# =================================================================
Write-Host "[+] Applying 'Hidden' attribute using attrib.exe..." -ForegroundColor Cyan
attrib.exe +h "$FilePath"

Write-Host "[+] Post-Execution Attributes:"
Get-Item $FilePath -Force | Select-Object FullName, Attributes | Format-Table

# =================================================================
# 3. Local Threat Hunting (Sysmon Telemetry)
# =================================================================
Write-Host "--- Threat Hunting: Querying Sysmon Logs (Last 30 mins) ---" -ForegroundColor Yellow
try {
    $start = (Get-Date).AddMinutes(-30)
    Get-WinEvent -FilterHashtable @{
        LogName='Microsoft-Windows-Sysmon/Operational';
        StartTime=$start;
        Id=@(1,11,15)
    } -ErrorAction Stop | Select-Object TimeCreated, Id, Message | Select-Object -First 3 | Format-List
} catch {
    Write-Host "[-] No recent Sysmon events found or Sysmon is not installed." -ForegroundColor Gray
}

# =================================================================
# 4. Cleanup Phase
# =================================================================
Write-Host "--- Cleanup Phase ---" -ForegroundColor Cyan
Write-Host "[+] Removing Hidden/System attributes and deleting file..."
attrib -h -s "$FilePath" 2>$null
Remove-Item "$FilePath" -Force

if (-not (Test-Path $FilePath)) {
    Write-Host "[+] Cleanup successful! File deleted." -ForegroundColor Green
} else {
    Write-Host "[-] Cleanup failed. Please delete manually." -ForegroundColor Red
}