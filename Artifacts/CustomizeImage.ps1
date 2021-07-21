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
