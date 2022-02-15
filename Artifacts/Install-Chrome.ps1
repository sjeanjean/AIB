#region Set logging 
$logFile = $env:SystemRoot + "\Temp\" + (get-date -format 'yyyyMMdd') + '_ChromeInstall.log'
function Write-Log {
    Param($message)
    Write-Output "$(get-date -format 'yyyyMMdd HH:mm:ss') $message" | Out-File -Encoding utf8 $logFile -Append
}
#endregion

#region Install OneDrive
azcopy copy https://bycnitaibsources.blob.core.windows.net/sources/googlechromestandaloneenterprise64.msi c:\temp
$file = Get-ChildItem 'c:\temp\googlechromestandaloneenterprise64.msi'
try {
    $MSIArguments = @(
        "/i"
        ('"{0}"' -f $file.fullname)
        "/qn"
        "/norestart"
        "/L*v"
        $logFile
    )  
    Start-Process -FilePath "$env:systemroot\system32\msiexec.exe" -Wait -ErrorAction Stop -ArgumentList $MSIArguments
        if (Test-Path "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe") {
        Write-Log "Chrome has been installed"
    }
    else {
        write-log "Error locating the Chrome executable"
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-log "Error installing Chrome: $ErrorMessage"
}
#endregion

azcopy copy https://bycnitaibsources.blob.core.windows.net/sources/googlechromestandaloneenterprise64.msi c:\temp

$preference_file = 'C:\Program Files (x86)\Google\Chrome\Application\master_preferences'
$pref = Get-Content $preference_file | ConvertFrom-Json

#region Disable automatic updates
#endregion

#region Disable Active Setup
#endregion

#region Remove the Chrome desktop icon
#endregion

#$pref | ConvertTo-Json | set-content $preference_file