param([switch]$Release)
Set-Location $PSScriptRoot
$phone = flutter devices --machine | ConvertFrom-Json | Where-Object { $_.targetPlatform -like 'android*' } | Select-Object -First 1
if (-not $phone) {
    Write-Host 'No phone found. Plug it in, unlock it and allow USB debugging.'
    exit 1
}
flutter pub get
if ($Release) { flutter run --release -d $phone.id } else { flutter run -d $phone.id }
