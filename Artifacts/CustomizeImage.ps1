#region Set logging 
$logFile = $env:SystemRoot + "\Temp\" + (get-date -format 'yyyyMMdd') + '_customizeinstall.log'
function Write-Log {
    Param($message)
    Write-Output "$(get-date -format 'yyyyMMdd HH:mm:ss') $message" | Out-File -Encoding utf8 $logFile -Append
}
#endregion

#region Time Zone Redirection
$RPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
$Name = "fEnableTimeZoneRedirection"
$value = "1"
# Add Registry value
try {
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

#region Disable Windows Search
Set-Service -Name WSearch -StartupType Disabled
#endregion

#region Disable Windows Store
$RPath = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
$Name = "RemoveWindowsStore"
$value = "1"
# Create the key if it does not exist
try {
    If (-NOT (Test-Path $RPath)) {
        New-Item -Path $RPath -Force | Write-Log
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-log "Error creating key $RPath : $ErrorMessage"
}
try {
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

#region Remove Lock Menu
$RPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$Name = "DisableLockWorkstation"
$value = "1"
try {
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

#region Remove Disconnect  menu
$RPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
$Name = "NoDisconnect"
$value = "1"
try {
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