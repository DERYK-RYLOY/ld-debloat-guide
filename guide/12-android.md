# 12 — Android side

## Objective

Apply the in-guest portion over ADB: disable LD's own apps, force ad-blocking DNS, and restore the preferred launcher HOME. This lives inside `data.vmdk` and is independent of the Windows-side sweep.

## 1. Start the emulator and expose ADB

```powershell
& 'C:\LDPlayer\LDPlayer9\ldconsole.exe' launch --index 0
& 'C:\LDPlayer\LDPlayer9\adb.exe' devices
```

`emulator-5554  device` must appear. If not: **LDPlayer → gear → Other → ADB debugging: ON**. Updates and fresh instances reset this switch.

## 2. Install replacements (requires local APKs)

```powershell
$adb = 'C:\LDPlayer\LDPlayer9\adb.exe'
& $adb install -r 'C:\ld-apps\Lawnchair.apk'
& $adb install -r 'C:\ld-apps\Aurora.apk'
& $adb install -r 'C:\ld-apps\Magisk.apk'
& $adb shell pm list packages -3
```

Sources: Lawnchair releases (`github.com/LawnchairLauncher/lawnchair`), Aurora Store (`f-droid.org/packages/com.aurora.store`), Magisk releases (`github.com/topjohnwu/Magisk/releases`). Verify packages with `aapt dump badging` before installing.

## 3. Auto re-apply (recommended)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\android-refresh.ps1
```

The script pattern-matches LD packages (`launcher3`, `ld.appstore`, `printspooler`, `dreams.phototable`, `ld.market`, `ldmnq`), sets Private DNS to `dns.adguard.com`, and sets Lawnchair as HOME when installed.

## 4. Manual equivalents

```powershell
$adb = 'C:\LDPlayer\LDPlayer9\adb.exe'
& $adb shell settings put global private_dns_mode hostname
& $adb shell settings put global private_dns_specifier dns.adguard.com
Get-ChildItem 'C:\LDPlayer\LDPlayer9\vms\config' -Filter '*.config' | Out-Null

# list and disable matched packages
$pkts = (& $adb shell pm list packages | Out-String) -replace 'package:','' -split "`r?`n"
$pkts | Where-Object { $_ -match 'launcher3|ld\.appstore|printspooler|dreams\.phototable|ld\.market|ldmnq' } |
  ForEach-Object { & $adb shell pm disable-user --user 0 $_ }
& $adb shell cmd package set-home-activity ch.deletescape.lawnchair/ch.deletescape.lawnchair.Launcher
```

## 5. Root (manual step)

Magisk → Install → Direct install → Reboot. Verify:

```powershell
& 'C:\LDPlayer\LDPlayer9\adb.exe' shell 'su -c id'   # uid=0(root)
```

## 6. Verify

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\verify-android.ps1
"exit=$LASTEXITCODE"
```

## Failure modes

| Symptom | Fix |
|---|---|
| `adb devices` empty | Enable ADB debugging in the guest; check LDPlayer → gear → Other |
| Lawnchair "not installed" | Install the APK first |
| `su: not found` | Magisk Direct install not done |
| HOME resets after update | Update re-imaged `data.vmdk` — re-run `android-refresh.ps1` |

**Next:** [13 — Maintenance](13-maintenance.md)
