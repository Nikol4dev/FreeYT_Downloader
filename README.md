# Downloader

Save YouTube videos, music, clips and playlists on Android and Windows.

## Download

Get the latest version from the [Releases](../../releases/latest) page.

| Device | File |
|---|---|
| Android (most phones) | `Downloader-android-arm64.apk` |
| Android (older 32-bit phones) | `Downloader-android-armv7.apk` |
| Windows 10/11 (64-bit) | `Downloader-windows.zip` |

## Install

### Android

1. Download the APK on your phone and open it.
2. Allow installing apps from your browser or file manager when asked.
3. If Play Protect warns about an unknown app, tap **More details → Install anyway**.

Requires Android 7.0 or newer.

### Windows

1. Download the zip and extract it anywhere.
2. Run `Downloader.exe`.
3. If Windows shows "Windows protected your PC", click **More info → Run anyway**.
4. On first use the app downloads its tools (yt-dlp, ffmpeg, deno, about 200 MB). This happens once.
5. If a DLL is reported missing, install the [Microsoft Visual C++ Redistributable](https://learn.microsoft.com/cpp/windows/latest-supported-vc-redist).

## How to use

- **Download:** paste a YouTube link (or share it from the YouTube app on Android), pick a quality, tap **Download**.
- **Clip:** turn on **Clip**, play the preview, tap **Start here** and **End here**, then **Download clip**.
- **Playlist:** paste a playlist link, choose the videos, tap **Download**.
- **Several links:** copy them together and tap **Paste**.
- **Queue:** pause, resume or cancel each download.
- **Library:** search, sort, favorites and playlists. Long-press to select several. **Import** adds files already in your download folder.
- **Player:** double-tap to skip 10 s, hold for 2× speed, ⚙ for speed, subtitles and loop. On Windows, double-click for fullscreen and use Space, ←/→, J/L, M, F and Esc.
- **Settings:** default quality, downloads at once, folder, subtitles, SponsorBlock and auto-update.

Files are saved to `Movies/Downloader` and `Music/Downloader` on Android, and `Videos\Downloader` and `Music\Downloader` on Windows, unless you choose another folder in Settings.

## Troubleshooting

- **Download fails or YouTube asks for a bot check:** Settings → **Update engine**, then retry.
- **Downloads stop in the background (Android):** set the app's battery usage to **Unrestricted**.
- **Import finds nothing (Android):** allow media access, then tap **Import** again.

## Build from source

Requirements: Flutter (stable), Android SDK for Android, Visual Studio with "Desktop development with C++" for Windows.

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart run flutter_launcher_icons
```

Run:

```powershell
.\run_windows.ps1            # add -Release for an optimized build
.\run_phone.ps1              # phone connected with USB debugging
```

Build:

```powershell
.\build_windows.ps1          # build\windows\x64\runner\Release
.\build_phone.ps1            # build\app\outputs\flutter-apk
```

If PowerShell blocks the scripts, run them with `powershell -ExecutionPolicy Bypass -File .\run_windows.ps1`.

## Note

For personal use. Respect YouTube's Terms of Service and copyright law.

## Credits

[yt-dlp](https://github.com/yt-dlp/yt-dlp), [youtubedl-android](https://github.com/JunkFood02/youtubedl-android), [FFmpeg](https://ffmpeg.org), [media_kit](https://github.com/media-kit/media-kit), [drift](https://drift.simonbinder.eu), [Riverpod](https://riverpod.dev)
