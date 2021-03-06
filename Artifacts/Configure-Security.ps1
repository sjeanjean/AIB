#region Set logging 
$logFile = $env:SystemRoot + "\Temp\" + (get-date -format 'yyyyMMdd') + '_ConfigureSecurity.log'
function Write-Log {
    Param($message)
    Write-Output "$(get-date -format 'yyyyMMdd HH:mm:ss') $message" | Out-File -Encoding utf8 $logFile -Append
}
#endregion

Write-Host (get-date -format 'yyyy/MM/dd HH:mm:ss') '================ Configure Security ========================'

#region Configure ACL
$acl = Get-Acl c:\
$rules = $acl.Access | Where { $_.IdentityReference.value -eq 'NT AUTHORITY\Authenticated Users' }
foreach($rule in $rules) { $acl.RemoveAccessRule($rule) }
$acl | Set-Acl c:\

$acl = Get-Acl C:\Windows\System32\Spool\drivers\color
$rules = $acl.Access | Where { $_.IdentityReference.value -eq 'BUILTIN\Users' }
foreach($rule in $rules) { $acl.RemoveAccessRule($rule) }
$acl | Set-Acl C:\Windows\System32\Spool\drivers\color

$acl = Get-Acl C:\Windows\Tracing
$rules = $acl.Access | Where { $_.IdentityReference.value -eq 'BUILTIN\Users' }
foreach($rule in $rules) { $acl.RemoveAccessRule($rule) }
$acl | Set-Acl C:\Windows\Tracing

$acl = Get-Acl C:\Windows\Tasks
$rules = $acl.Access | Where { $_.IdentityReference.value -eq 'NT AUTHORITY\Authenticated Users' }
foreach($rule in $rules) { $acl.RemoveAccessRule($rule) }
$acl | Set-Acl C:\Windows\Tasks

Write-Log (get-date -format 'yyyy/MM/dd HH:mm:ss') '================ Securing ACL done ========================'
#endregion

#region Turn On DEP
Start-Process -NoNewWindow -FilePath "bcdedit.exe" -ArgumentList "/set {current} nx AlwaysOn" -RedirectStandardOutput $logFile
#endregion

$RPath = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features"
$Name = "TamperProtection"
$value = 5
# Add Registry value
try {
    # Create the key if it does not exist
    If (-NOT (Test-Path $RPath)) {
        New-Item -Path $RPath -Force | Write-Log
    }
    New-ItemProperty -ErrorAction Stop -Path $RPath -Name $name -Value $value -PropertyType DWORD -Force
    if ((Get-ItemProperty $RPath).PSObject.Properties.Name -contains $name) {
        Write-log "Added $Name registry key"
    }
    else {
        write-log "Error locating the $Name registry key"
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-log "Error adding $Name registry KEY: $ErrorMessage"
}
#endregion

#region Enable Memory Integrity (No compatible with SIG images)
<#
$RPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
$Name = "Enabled"
$value = 1
try {
    # Create the key if it does not exist
    If (-NOT (Test-Path $RPath)) {
        New-Item -Path $RPath -Force | Write-Log
    }
    New-ItemProperty -ErrorAction Stop -Path $RPath -Name $name -Value $value -PropertyType DWORD -Force
    if ((Get-ItemProperty $RPath).PSObject.Properties.Name -contains $name) {
        Write-log "Added $Name registry key"
    }
    else {
        write-log "Error locating the $Name registry key"
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-log "Error adding $Name registry KEY: $ErrorMessage"
}
#>
#endregion

#region Enable Windows Defender SmartScreen on Block
$RPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
$Name = "EnableSmartScreen"
$value = 1
try {
    # Create the key if it does not exist
    If (-NOT (Test-Path $RPath)) {
        New-Item -Path $RPath -Force | Write-Log
    }
    New-ItemProperty -ErrorAction Stop -Path $RPath -Name $name -Value $value -PropertyType DWORD -Force
    if ((Get-ItemProperty $RPath).PSObject.Properties.Name -contains $name) {
        Write-log "Added $Name registry key"
    }
    else {
        write-log "Error locating the $Name registry key"
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-log "Error adding $Name registry KEY: $ErrorMessage"
}
$Name = "ShellSmartScreenLevel"
$value = "Block"
try {
    New-ItemProperty -ErrorAction Stop -Path $RPath -Name $name -Value $value -PropertyType String -Force
    if ((Get-ItemProperty $RPath).PSObject.Properties.Name -contains $name) {
        Write-log "Added $Name registry key"
    }
    else {
        write-log "Error locating the $Name registry key"
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-log "Error adding $Name registry KEY: $ErrorMessage"
}
#endregion

Write-Host (get-date -format 'yyyy/MM/dd HH:mm:ss') '================ Configure Security Done ====================='
