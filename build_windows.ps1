Set-Location $PSScriptRoot
flutter build windows --release
$out = 'build\windows\x64\runner\Release'
if (Test-Path 'C:\Tools\yt\yt-dlp.exe') {
    New-Item -ItemType Directory -Force "$out\tools" | Out-Null
    Copy-Item 'C:\Tools\yt\*.exe' "$out\tools\" -Force
}
Write-Host "App folder: $((Resolve-Path $out).Path)"
