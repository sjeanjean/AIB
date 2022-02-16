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
        if (Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe") {
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

$preference_file = 'C:\Program Files\Google\Chrome\Application\master_preferences'
$pref = Get-Content $preference_file | ConvertFrom-Json

#region Disable automatic updates
Stop-Service gpupdate
Stop-Service gpupdatem
Set-Service -Name gupdate -StartupType Disabled 
Set-Service -Name gupdatem -StartupType Disabled 
Unregister-ScheduledTask -TaskName GoogleUpdateTaskMachineCore* -Confirm:$false
Unregister-ScheduledTask -TaskName GoogleUpdateTaskMachineUA* -Confirm:$false
#endregion

#region Disable Active Setup
#endregion

#region Remove the Chrome desktop icon
#endregion

$pref | add-member -name 'homepage' -value "https://insideplus.bouygues-es-intec.com/" -MemberType NoteProperty
$pref | add-member -name 'homepage_is_newtabpage' -value "false" -MemberType NoteProperty
$session = [PSCustomObject]@{
    startup_urls = @(
        'https://insideplus.bouygues-es-intec.com/'
    )
}
$pref | add-member -name 'session' -value $session -MemberType NoteProperty

$pref | ConvertTo-Json | set-content $preference_file