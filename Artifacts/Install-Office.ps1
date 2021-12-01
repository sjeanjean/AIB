#region Set logging 
$logFile = $env:SystemRoot + "\Temp\" + (get-date -format 'yyyyMMdd') + '_Office.log'
function Write-Log {
    Param($message)
    Write-Output "$(get-date -format 'yyyyMMdd HH:mm:ss') $message" | Out-File -Encoding utf8 $logFile -Append
}
#endregion

Write-Host "--------------- Start Install-Office -------------"
#region Install OneDrive
azcopy copy https://bycnitaibsources.blob.core.windows.net/sources/Office/Office.xml c:\temp
azcopy copy https://bycnitaibsources.blob.core.windows.net/sources/Office/setup.exe c:\temp
try {
    Start-Process -FilePath 'c:\temp\setup.exe' -Wait -ErrorAction Stop -ArgumentList '/configure', 'c:\temp\Office.xml'
        if (Test-Path "C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE") {
        Write-Log "Office has been installed"
    }
    else {
        write-log "Error locating the Office executable"
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-log "Error installing Office: $ErrorMessage"
}
#endregion
Write-Host "--------------- End Install-Office -------------"
