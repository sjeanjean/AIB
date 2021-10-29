#region Set logging 
$logFile = $env:SystemRoot + "\Temp\" + (get-date -format 'yyyyMMdd') + '_ConfigureSecurity.log'
function Write-Log {
    Param($message)
    Write-Output "$(get-date -format 'yyyyMMdd HH:mm:ss') $message" | Out-File -Encoding utf8 $logFile -Append
}
#endregion

#region Enable Tamper Protection
$RPath = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features"
$Name = "TamperProtection "
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

#region Enable Memory Integrity
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