Set-Location $PSScriptRoot
$keytool = 'C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe'
if (-not (Test-Path $keytool)) { $keytool = 'keytool' }
if (Test-Path 'android\upload-keystore.jks') { Write-Host 'Key already exists.'; exit 0 }
$pass = Read-Host 'Choose a key password (at least 6 characters)'
& $keytool -genkeypair -v -keystore android\upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload -storepass $pass -keypass $pass -dname 'CN=Downloader'
@"
storePassword=$pass
keyPassword=$pass
keyAlias=upload
storeFile=upload-keystore.jks
"@ | Set-Content android\key.properties
Write-Host 'Done. Back up android\upload-keystore.jks and your password somewhere safe.'
