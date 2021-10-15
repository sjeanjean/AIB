#region Set logging 
$logFile = $env:SystemRoot + "\Temp\" + (get-date -format 'yyyyMMdd') + '_OneDriveInstall.log'
function Write-Log {
    Param($message)
    Write-Output "$(get-date -format 'yyyyMMdd HH:mm:ss') $message" | Out-File -Encoding utf8 $logFile -Append
}
#endregion

#region Install OneDrive
azcopy copy https://bycnitaibsources.blob.core.windows.net/sources/OneDriveSetup.exe c:\temp
try {
    Start-Process -FilePath 'c:\temp\OneDriveSetup.exe' -Wait -ErrorAction Stop -ArgumentList '/silent', '/allusers'
        if (Test-Path "C:\Program Files (x86)\Microsoft OneDrive\OneDrive.exe") {
        Write-Log "OneDrive has been installed"
    }
    else {
        write-log "Error locating the OneDrive executable"
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-log "Error installing OneDrive: $ErrorMessage"
}
#endregion

#region Prevent users from redirecting their Windows known folders to their PC
$RPath = "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive"
$Name = "KFMBlockOptOut"
$value = "1"
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

#region Disable ScheduledTask "OneDrive Per-Machine Standalone Update Task"
Disable-ScheduledTask -TaskName "OneDrive Per-Machine Standalone Update Task"
#endregion