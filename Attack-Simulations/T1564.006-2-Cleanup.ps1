<#
.SYNOPSIS
    Cleans up the VirtualBox VM created by Atomic Test T1564.006-2.

.DESCRIPTION
    1. Checks if the "Atomic VM" exists.
    2. Powers off the VM if it's running.
    3. Unregisters and deletes the VM and its files completely.
#>

$VBoxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$VMName = "Atomic VM"

Write-Host "Starting Cleanup for Atomic Test T1564.006-2 (VM: $VMName)" -ForegroundColor Yellow

if (-not (Test-Path $VBoxManage)) {
    Write-Host "ERROR: VBoxManage.exe not found at $VBoxManage." -ForegroundColor Red
    exit 1
}

Write-Host "`n--- Cleanup Phase: Deleting VM ---" -ForegroundColor Cyan

try {
    Write-Host "Checking if VM '$VMName' exists..."
    $VMList = & "$VBoxManage" list vms
    $VMExists = $VMList -match "`"$VMName`""
    
    if (-not $VMExists) {
        Write-Host "VM '$VMName' not found. Nothing to clean up." -ForegroundColor Green
        exit 0
    }

    Write-Host "[1/3] Checking if VM '$VMName' is running..."
    $RunningVMs = & "$VBoxManage" list runningvms
    $VMRunning = $RunningVMs -match "`"$VMName`""
    
    if ($VMRunning) {
        Write-Host "VM is running. Attempting to power off..." -ForegroundColor Yellow
        & "$VBoxManage" controlvm "$VMName" poweroff
        Start-Sleep -Seconds 5
    }

    Write-Host "[2/3] Unregistering and deleting VM '$VMName'..."
    & "$VBoxManage" unregistervm "$VMName" --delete
    
    Write-Host "[3/3] Verifying deletion..."
    Start-Sleep -Seconds 2
    $VMListAfter = & "$VBoxManage" list vms
    
    if (-not ($VMListAfter -match "`"$VMName`"")) {
        Write-Host "`n✅ SUCCESS: VM '$VMName' has been completely deleted." -ForegroundColor Green
    } else {
        Write-Host "`n⚠️ WARNING: VM may not have been fully deleted." -ForegroundColor Yellow
    }

} catch {
    Write-Host "`n❌ ERROR during cleanup: $($_.Exception.Message)" -ForegroundColor Red
}