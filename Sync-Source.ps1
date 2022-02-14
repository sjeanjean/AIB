# Synchronize local source folder to AIB source Blob

#azcopy login

$localSourceFolder = 'C:\Users\S.JEANJEAN\BYCN_Online\OneDrive - BYCN\Documents\Intec\AIB\source'
$remoteSourceFolder = 'https://bycnitaibsources.blob.core.windows.net/sources'
azcopy sync $localSourceFolder $remoteSourceFolder --recursive

$localSourceFolder = 'C:\Users\S.JEANJEAN\BYCN_Online\OneDrive - BYCN\Documents\Intec\AIB\LanguagesPacks21H2\LanguagesPacks.zip'
$remoteSourceFolder = 'https://bycnitaibsources.blob.core.windows.net/languagepacks\21h2'
azcopy copy $localSourceFolder $remoteSourceFolder 