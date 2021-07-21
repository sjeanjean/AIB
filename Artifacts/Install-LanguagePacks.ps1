########################################################
## Add Languages to running Windows Image for Capture##
########################################################

#region Set logging 
$logFile = $env:SystemRoot + "\Temp\" + (get-date -format 'yyyyMMdd') + 'Install-LanguagesPacks.log'
function Write-Log {
    Param($message)
    Write-Output "$(get-date -format 'yyyyMMdd HH:mm:ss') $message" | Out-File -Encoding utf8 $logFile -Append
}
#endregion

##Disable Language Pack Cleanup##
Disable-ScheduledTask -TaskPath "\Microsoft\Windows\AppxDeploymentClient\" -TaskName "Pre-staged app cleanup"

##Set Language Pack Content Stores##
[string]$LIPContent = "C:\temp\LanguagesPacks"

##Copy language Repository
azcopy copy https://bycnitaibsources.blob.core.windows.net/languagepacks/21h1/LanguagesPacks.zip c:\temp
Expand-Archive C:\temp\LanguagesPacks.zip -DestinationPath $LIPContent



##French##
Add-AppProvisionedPackage -Online -PackagePath $LIPContent\fr-fr\LanguageExperiencePack.fr-fr.Neutral.appx -LicensePath $LIPContent\fr-fr\License.xml
Add-WindowsPackage -Online -PackagePath $LIPContent\Microsoft-Windows-Client-Language-Pack_x64_fr-fr.cab
Add-WindowsPackage -Online -PackagePath $LIPContent\Microsoft-Windows-LanguageFeatures-Basic-fr-fr-Package~31bf3856ad364e35~amd64~~.cab
Add-WindowsPackage -Online -PackagePath $LIPContent\Microsoft-Windows-LanguageFeatures-Handwriting-fr-fr-Package~31bf3856ad364e35~amd64~~.cab
Add-WindowsPackage -Online -PackagePath $LIPContent\Microsoft-Windows-LanguageFeatures-OCR-fr-fr-Package~31bf3856ad364e35~amd64~~.cab
Add-WindowsPackage -Online -PackagePath $LIPContent\Microsoft-Windows-LanguageFeatures-Speech-fr-fr-Package~31bf3856ad364e35~amd64~~.cab
Add-WindowsPackage -Online -PackagePath $LIPContent\Microsoft-Windows-LanguageFeatures-TextToSpeech-fr-fr-Package~31bf3856ad364e35~amd64~~.cab

##German##
Add-AppProvisionedPackage -Online -PackagePath $LIPContent\de-de\LanguageExperiencePack.de-de.Neutral.appx -LicensePath $LIPContent\de-de\License.xml
Add-WindowsPackage -Online -PackagePath $LIPContent\Microsoft-Windows-Client-Language-Pack_x64_de-de.cab
Add-WindowsPackage -Online -PackagePath $LIPContent\Microsoft-Windows-LanguageFeatures-Basic-de-de-Package~31bf3856ad364e35~amd64~~.cab
Add-WindowsPackage -Online -PackagePath $LIPContent\Microsoft-Windows-LanguageFeatures-Handwriting-de-de-Package~31bf3856ad364e35~amd64~~.cab
Add-WindowsPackage -Online -PackagePath $LIPContent\Microsoft-Windows-LanguageFeatures-OCR-de-de-Package~31bf3856ad364e35~amd64~~.cab
Add-WindowsPackage -Online -PackagePath $LIPContent\Microsoft-Windows-LanguageFeatures-Speech-de-de-Package~31bf3856ad364e35~amd64~~.cab
Add-WindowsPackage -Online -PackagePath $LIPContent\Microsoft-Windows-LanguageFeatures-TextToSpeech-de-de-Package~31bf3856ad364e35~amd64~~.cab

#region Block clean-up of unused language packs
$RPath = "HKLM:\SOFTWARE\Policies\Microsoft\Control Panel\International"
$Name = "BlockCleanupOfUnusedPreinstalledLangPacks"
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

##region Add ActiveSetup for configure UserLanguageList
try {
    New-Item -Path Registry::'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components' -Name 'OSD-ConfigurePreferredUserLangages'
    New-ItemProperty -Path Registry::'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\OSD-ConfigurePreferredUserLangages' `
                     -Name 'Version' `
                     -Value '1,0,0,0' `
                     -PropertyType 'String'
    New-ItemProperty -Path Registry::'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\OSD-ConfigurePreferredUserLangages' `
                     -Name 'StubPath' `
                     -Value 'Powershell.exe -ExecutionPolicy bypass -WindowStyle Hidden -NonInteractive -command "$list=Get-WinUserLanguageList; $list.Add(''de-ch''); $list.Add(''de-de''); $list.Add(''fr-ch''); $list.Add(''it-ch''); $list.Add(''it-it''); $list.Add(''fr-fr''); Set-WinUserLanguageList -LanguageList $list -Force"' `
                     -PropertyType 'String'
    if ((Get-ItemProperty $Registry::'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\OSD-ConfigurePreferredUserLangages').PSObject.Properties.Name -contains 'Version') {
        Write-log "Added Active Setup registry key"
    }
    else {
        write-log "Error locating the Active Setup registry key"
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-log "Error adding Active Setup registry KEY: $ErrorMessage"
}#endregion