# 17 — App compatibility

## Objective

Make the guest run modern and legacy APKs: correct Android profile, ABI support, GMS readiness, clean install verification.

## Read the guest profile (read-only)

```powershell
$adb = 'C:\LDPlayer\LDPlayer9\adb.exe'
& $adb shell getprop ro.build.version.release
& $adb shell getprop ro.build.version.sdk
& $adb shell getprop ro.product.cpu.abi
& $adb shell getprop ro.product.cpu.abilist
& $adb shell pm list features
```

LDPlayer 9 guests are 64-bit x86 (`x86_64`) with Android 9-class APIs. Titles shipping only ARM native libraries need translation.

## Verify an APK before installing

```powershell
$aapt = 'C:\LDPlayer\LDPlayer9\aapt.exe'
& $aapt dump badging 'C:\Users\Admin\Downloads\ld-apps\Lawnchair.apk' |
  Select-String 'package:|sdkVersion:|targetSdkVersion:|native-code:|uses-permission:'
```

Check: package name, min/target SDK, and whether the APK contains `armeabi-v7a`/`arm64-v8a` only.

## Install and verify

```powershell
$adb = 'C:\LDPlayer\LDPlayer9\adb.exe'
& $adb install -r 'C:\path\to\app.apk'
& $adb shell pm path <package>          # installed path
& $adb shell dumpsys package <package> | Select-String 'versionName|targetSdk|firstInstallTime'
```

## ARM translation (LDPlayer UI)

Settings → Other → **ARM translation** / native bridge (name varies by build). Enable it for titles with ARM-only `.so` libraries; disable again for pure x86 titles to avoid translation overhead.

## GMS / Play readiness

- LDPlayer ships Google Play services in most builds; confirm with `adb shell pm list packages | Select-String 'google'`.
- Play "certified/unofficial" warnings are informational for sideloaded apps; they do not block most titles.
- Do not install random GMS bundles from untrusted sources.

## Failure modes

| Symptom | Fix |
|---|---|
| `INSTALL_FAILED_NO_MATCHING_ABIS` | Enable ARM translation for that install |
| App launches then exits | Check logcat: `adb logcat -d -t 200 | Select-String -Pattern 'FATAL|Exception|dlopen'` |
| "Device not compatible" on Play | Sideload the official APK rather than changing identity blindly |
| Missing permission prompt | `adb shell pm grant <pkg> android.permission.<NAME>` for runtime permissions |

## Boundary

Use compatibility features for apps/games that refuse to run for benign reasons. Do not use them to bypass competitive anti-cheat or integrity checks; respect the title's terms.

**Next:** [18 — Device identity](18-device-identity.md)
