#region Set logging 
$logFile = "c:\temp\" + (get-date -format 'yyyyMMdd') + '_softwareinstall.log'
function Write-Log {
    Param($message)
    Write-Output "$(get-date -format 'yyyyMMdd HH:mm:ss') $message" | Out-File -Encoding utf8 $logFile -Append
}
#endregion

#region Install OneDrive
"azcopy copy https://bycnitaibsources.blob.core.windows.net/sources/OneDriveSetup.exe c:\\temp"
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