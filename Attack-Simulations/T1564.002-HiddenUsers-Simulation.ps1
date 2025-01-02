<#
.SYNOPSIS
    Simulates MITRE ATT&CK T1564.002 (Hidden Users) using Atomic Red Team.

.DESCRIPTION
    1. Executes AtomicTest T1564.002-3 (Create Hidden User in Registry).
    2. Verifies the user creation via 'net user' and Registry query.
    3. Performs environment cleanup (Requires caution for forensics).
#>

Write-Host "--- Starting Attack Simulation: T1564.002 (Hidden Users) ---" -ForegroundColor Yellow

# =================================================================
# 1. Execution Phase (Defense Evasion)
# =================================================================
Write-Host "[+] Executing Atomic Test T1564.002-3 (Create Hidden User in Registry)..." -ForegroundColor Cyan
Invoke-AtomicTest T1564.002 -TestNumbers 3

# =================================================================
# 2. Verification Phase
# =================================================================
Write-Host "`n--- Verification ---" -ForegroundColor Yellow

Write-Host "[+] Listing local users (Checking if hidden user appears)..."
net user

Write-Host "`n[+] Querying the Registry for SpecialAccounts\Userlist..."
try {
    reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\Userlist"
} catch {
    Write-Host "[-] Registry key not found or access denied." -ForegroundColor Red
}

# =================================================================
# 3. Cleanup & Forensics Warning
# =================================================================
Write-Host "`n--- Cleanup Phase ---" -ForegroundColor Cyan
Write-Host "⚠️ IMPORTANT SEC-OPS WARNING:" -ForegroundColor Red
Write-Host "The cleanup script disables the account and removes the registry entry." -ForegroundColor Gray
Write-Host "Run this only if you have decided on actual response and collected forensic evidence.`n" -ForegroundColor Gray

$ConfirmCleanup = Read-Host "Proceed with cleanup? (Y/N)"
if ($ConfirmCleanup -match "^[Yy]$") {
    Write-Host "[+] Running Atomic Red Team Cleanup..." -ForegroundColor Cyan
    Invoke-AtomicTest T1564.002 -TestNumbers 3 -Cleanup
    Write-Host "[+] Cleanup completed successfully." -ForegroundColor Green
} else {
    Write-Host "[-] Cleanup aborted. Evidence preserved for forensic analysis." -ForegroundColor Yellow
}