# 12 — Android side (Lawnchair)

## Objective

Set Lawnchair as the guest HOME app and disable LD's own launcher/app-store over ADB. This lives inside `data.vmdk`; it is independent of the Windows-side sweep. Aurora Store, Magisk and root are out of scope.

## 1. Expose ADB

```powershell
& 'C:\LDPlayer\LDPlayer9\ldconsole.exe' launch --index 0
& 'C:\LDPlayer\LDPlayer9\adb.exe' devices
```

`emulator-5554  device` must appear. If not: **LDPlayer → gear → Other → ADB debugging: ON**. Updates and fresh instances reset this switch.

## 2. Install Lawnchair

```powershell
$adb = 'C:\LDPlayer\LDPlayer9\adb.exe'
& $adb install -r "$env:USERPROFILE\Downloads\ld-apps\Lawnchair.apk"
& $adb shell pm list packages -3 | Select-String 'lawnchair'
```

Source: Lawnchair releases (`github.com/LawnchairLauncher/lawnchair`). Verify the package with `aapt dump badging` before installing.

## 3. Auto re-apply (recommended)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\android-refresh.ps1
```

The script pattern-matches LD packages (`launcher3`, `ld.appstore`, `printspooler`, `dreams.phototable`, `ld.market`, `ldmnq`), sets Private DNS to `dns.adguard.com`, and sets Lawnchair as HOME when installed. It is re-applied by `reapply-debloat.ps1` whenever the emulator is attached.

## 4. Manual equivalents

```powershell
$adb = 'C:\LDPlayer\LDPlayer9\adb.exe'
& $adb shell settings put global private_dns_mode hostname
& $adb shell settings put global private_dns_specifier dns.adguard.com
$pkts = (& $adb shell pm list packages | Out-String) -replace 'package:','' -split "`r?`n"
$pkts | Where-Object { $_ -match 'launcher3|ld\.appstore|printspooler|dreams\.phototable|ld\.market|ldmnq' } |
  ForEach-Object { & $adb shell pm disable-user --user 0 $_ }
& $adb shell cmd package set-home-activity ch.deletescape.lawnchair/ch.deletescape.lawnchair.Launcher
```

## 5. Verify

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\verify-android.ps1
"exit=$LASTEXITCODE"
```

Checks: Lawnchair installed, Private DNS = adguard, Lawnchair is HOME, LD packages disabled, no promoted LD packages remain.

## Failure modes

| Symptom | Fix |
|---|---|
| `adb devices` empty | Enable ADB debugging in the guest; gear → Other → ADB debugging: ON |
| Lawnchair "not installed" | Install the APK first (step 2) |
| HOME resets after update | Update re-imaged `data.vmdk` — re-run `android-refresh.ps1` |
| ADB off again | Re-enable after every update |

**Next:** [13 — Maintenance](13-maintenance.md)
