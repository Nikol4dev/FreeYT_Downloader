Set-Location $PSScriptRoot
flutter build apk --release --split-per-abi --target-platform android-arm,android-arm64
Get-ChildItem build\app\outputs\flutter-apk\*.apk | Select-Object Name, @{n='MB'; e={[math]::Round($_.Length/1MB,1)}}
$adb = Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'
if ((& $adb devices) -match "`tdevice") {
    & $adb install -r build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
} else {
    Write-Host 'No phone connected. APKs are in build\app\outputs\flutter-apk'
}
