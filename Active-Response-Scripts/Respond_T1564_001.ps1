# Respond_T1564_001.ps1
$F = "C:\Users\ra\Downloads\T1564.001.txt"
$Time = (Get-Date).ToString('yyyyMMdd_HHmmss')
$Out = "$env:USERPROFILE\Desktop\T1564_001_Evidence_$Time"
New-Item -Path $Out -ItemType Directory -Force | Out-Null

# 1. Capture file info before changes
Get-Item -Path $F -Force | Select-Object FullName, Attributes, Length, CreationTime, LastWriteTime | Out-File "$Out\File_before_attrs.txt"

# 2. Capture Sysmon and Security events around the timeframe (±15 minutes)
$start = (Get-Date).AddMinutes(-30)
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational'; StartTime=$start; Id=@(1,11,13)} |
  Where-Object { $_.Message -match [regex]::Escape($F) -or $_.Message -match 'attrib\.exe|powershell' } |
  Format-List TimeCreated, Id, Message -Width 2000 > "$Out\Sysmon_events.txt"

Get-WinEvent -FilterHashtable @{LogName='Security'; StartTime=$start; Id=@(4663,4656,4670,1102,4703)} |
  Format-List TimeCreated, Id, Message -Width 2000 > "$Out\Security_events.txt"

# 3. Export Wazuh alerts for this agent (run on manager) - placeholder instruction
"Run on manager: curl -u <USER>:<PASS> -k 'https://<WAZUH_MANAGER>:55000/alerts?agent_id=007&date_from=$(Get-Date -Format o -Date (Get-Date).AddHours(-3))' > /tmp/alerts_agent007.json" | Out-File "$Out\Fetch_Wazuh_on_Manager.txt"

# 4. Show current attributes
attrib "$F" > "$Out\attrib_before.txt"
Get-Item -Path $F -Force | Select-Object FullName, Attributes | Out-File "$Out\Item_after_create.txt"

# 5. Unhide file (non-destructive) and copy a safe copy
attrib -h -s "$F" 2>$null
Copy-Item -Path $F -Destination "$Out\T1564.001_copy_$Time.txt" -Force

# 6. Record attributes after unhide
attrib "$F" > "$Out\attrib_after_unhide.txt"
Get-Item -Path $F -Force | Select-Object FullName, Attributes | Out-File "$Out\Item_after_unhide.txt"

# 7. Hash the copied file
Get-FileHash -Algorithm SHA256 "$Out\T1564.001_copy_$Time.txt" | Out-File "$Out\hash_copy.txt"

Write-Output "Evidence saved to $Out"
