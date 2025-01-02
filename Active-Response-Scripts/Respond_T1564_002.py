# سكريبت اكتشاف واستجابة لهجوم إخفاء المستخدمين
function Detect-HiddenUsersAttack {
    param(
        [string]$AgentName,
        [string]$LogPath = "C:\Wazuh\logs\hidden_users_response.log"
    )
    
    function Log-Response {
        param([string]$Message)
        $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "$Timestamp - $Message" | Out-File -FilePath $LogPath -Append
        Write-Host $Message -ForegroundColor Yellow
    }
    
    Log-Response "بدء التحقيق في هجوم إخفاء المستخدمين على الجهاز: $AgentName"
    
    # 1. كشف الحسابات المخفية في UserList
    $UserListPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
    if (Test-Path $UserListPath) {
        $HiddenUsers = Get-ItemProperty -Path $UserListPath -ErrorAction SilentlyContinue
        if ($HiddenUsers) {
            Log-Response "تم اكتشاف الحسابات المخفية التالية:"
            $HiddenUsers.PSObject.Properties | Where-Object {$_.Name -notlike "PS*"} | ForEach-Object {
                Log-Response "حساب مخفي: $($_.Name) - القيمة: $($_.Value)"
            }
            
            # إجراء تصحيحي: إظهار الحسابات المخفية
            foreach ($user in $HiddenUsers.PSObject.Properties | Where-Object {$_.Name -notlike "PS*"}) {
                Set-ItemProperty -Path $UserListPath -Name $user.Name -Value 1
                Log-Response "تم إظهار الحساب: $($user.Name)"
            }
        }
    }
    
    # 2. فحص الخدمات النظامية المستهدفة
    $TargetServices = @("BITS", "bam", "W32Time", "Tcpip")
    foreach ($service in $TargetServices) {
        $servicePath = "HKLM:\System\CurrentControlSet\Services\$service"
        if (Test-Path $servicePath) {
            $acl = Get-Acl $servicePath
            if ($acl.Owner -eq "NT AUTHORITY\SYSTEM") {
                Log-Response "تحذير: مفتاح $service مملوك من SYSTEM - قد يكون مشبوهاً"
                
                # إعادة تعيين الملكية إلى Administrators
                $newOwner = "Administrators"
                try {
                    $acl.SetOwner([System.Security.Principal.NTAccount]$newOwner)
                    Set-Acl $servicePath $acl
                    Log-Response "تم إعادة تعيين ملكية $service إلى $newOwner"
                } catch {
                    Log-Response "خطأ في إعادة تعيين ملكية $service"
                }
            }
        }
    }
    
    # 3. فحص إعدادات BAM للمستخدم المستهدف
    $TargetUserSID = "S-1-5-21-2683549735-1919836698-619989629-1001"
    $BAMPath = "HKLM:\System\CurrentControlSet\Services\bam\State\UserSettings\$TargetUserSID"
    if (Test-Path $BAMPath) {
        Log-Response "تحذير: تم العثور على إعدادات BAM للمستخدم $TargetUserSID"
        
        # إنشاء نسخة احتياطية وحذف الإعدادات المشبوهة
        $backupPath = "C:\Backups\BAM_$TargetUserSID_$(Get-Date -Format 'yyyyMMdd_HHmmss').reg"
        reg export "HKLM\System\CurrentControlSet\Services\bam\State\UserSettings\$TargetUserSID" $backupPath
        Log-Response "تم إنشاء نسخة احتياطية من إعدادات BAM: $backupPath"
    }
    
    Log-Response "انتهاء التحقيق في هجوم إخفاء المستخدمين"
}

# تنفيذ السكريبت
Detect-HiddenUsersAttack -AgentName "DESKTOP-AGUDN4H"