# Respond_T1564_002.ps1
$UserName = 't1564_hidden'         # أو 'AtomicOperator$' إذا كان اسم القيمة هو اسم الحساب
$RegPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList'
$Time = (Get-Date).ToString('yyyyMMdd_HHmmss')
$Out = "$env:USERPROFILE\Desktop\T1564_002_Evidence_$Time"
New-Item -Path $Out -ItemType Directory -Force | Out-Null

# 1. Export registry key (backup evidence)
reg export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" "$Out\UserList_backup_$Time.reg" /y
Get-FileHash -Path "$Out\UserList_backup_$Time.reg" -Algorithm SHA256 | Out-File "$Out\UserList_backup_hash.txt"

# 2. Collect Sysmon & Security events (last 3 hours)
$start=(Get-Date).AddHours(-3)
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational'; StartTime=$start} |
  Where-Object { $_.Message -match 'SpecialAccounts|UserList|t1564_hidden|AtomicOperator\$' } |
  Format-List TimeCreated,Id,Message -Width 2000 > "$Out\Sysmon_events.txt"

Get-WinEvent -FilterHashtable @{LogName='Security'; StartTime=$start; Id=@(4720,4722,4732)} |
  Where-Object { $_.Message -match 't1564_hidden|AtomicOperator\$' } |
  Format-List TimeCreated,Id,Message -Width 2000 > "$Out\Security_events.txt"

# 3. Check existence of local user
Try {
  $u = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue
  if ($u) {
    # 4. Disable account (non-destructive)
    Disable-LocalUser -Name $UserName
    Write-Output "Disabled local user $UserName" | Out-File "$Out\action_log.txt" -Append
    # 5. Set random password (lock)
    $rnd = [System.Web.Security.Membership]::GeneratePassword(20,4)
    net user $UserName $rnd
    Write-Output "Changed password for $UserName" | Out-File "$Out\action_log.txt" -Append
  } else {
    Write-Output "Local user $UserName not found" | Out-File "$Out\action_log.txt" -Append
  }
} Catch { $_ | Out-File "$Out\action_log.txt" -Append }

# 6. Remove registry value that hides the account (after backup)
Try {
  if (Test-Path $RegPath) {
    # Get list of values for evidence
    reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" > "$Out\reg_values_before.txt"
    Remove-ItemProperty -Path $RegPath -Name $UserName -ErrorAction SilentlyContinue
    Write-Output "Removed registry value $UserName from UserList (if existed)" | Out-File "$Out\action_log.txt" -Append
    reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" > "$Out\reg_values_after.txt"
  }
} Catch { $_ | Out-File "$Out\action_log.txt" -Append }

# 7. Finalize evidence package
Get-ChildItem -Path $Out -Recurse | Out-File "$Out\evidence_index.txt"
Write-Output "Evidence and actions saved to $Out"
