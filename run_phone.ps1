param([switch]$Release)
Set-Location $PSScriptRoot
$adb = Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'
$serial = & $adb devices | Select-String '\sdevice$' | ForEach-Object { ($_.Line -split '\s+')[0] } | Select-Object -First 1
if (-not $serial) {
    Write-Host 'No phone found. Plug it in, unlock it and tap Allow on the USB debugging prompt.'
    & $adb devices
    exit 1
}
flutter pub get
if ($Release) { flutter run --release -d $serial } else { flutter run -d $serial }