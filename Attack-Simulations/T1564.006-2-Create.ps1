<#
.SYNOPSIS
    Creates and starts VirtualBox VM for Atomic Test T1564.006-2 (Attack Phase Only).

.DESCRIPTION
    1. Defines the path to VBoxManage.exe.
    2. Creates and registers a new VM named "Atomic VM".
    3. Modifies the VM firmware.
    4. Attempts to start the VM (The actual "attack" phase).
#>

$VBoxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$VMName = "Atomic VM"

Write-Host "Starting Atomic Test T1564.006-2 (Attack Phase) for VM: $VMName" -ForegroundColor Yellow

if (-not (Test-Path $VBoxManage)) {
    Write-Host "ERROR: VBoxManage.exe not found at $VBoxManage." -ForegroundColor Red
    exit 1
}

Write-Host "`n--- Attack Phase: Creating and Starting VM ---" -ForegroundColor Cyan

try {
    Write-Host "[1/3] Creating and registering VM '$VMName'..."
    & "$VBoxManage" createvm --name "$VMName" --register
    
    Write-Host "[2/3] Modifying VM settings (firmware efi)..."
    & "$VBoxManage" modifyvm "$VMName" --firmware efi

    Write-Host "[3/3] Attempting to start VM '$VMName' (Detection Point)..."
    & "$VBoxManage" startvm "$VMName"
    
    Write-Host "`n✅ Attack Phase Complete - VM '$VMName' created and started!" -ForegroundColor Green
    Write-Host "📝 Remember to run the cleanup script later." -ForegroundColor Yellow

} catch {
    Write-Host "`n⚠️ WARNING: VM start failed - $($_.Exception.Message)" -ForegroundColor Yellow
}