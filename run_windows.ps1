param([switch]$Release)
Set-Location $PSScriptRoot
flutter pub get
if ($Release) { flutter run --release -d windows } else { flutter run -d windows }
