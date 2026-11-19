# 18 — Device identity (compatibility)

## Objective

Present a **coherent** guest device identity. Many apps reject a guest because its model, fingerprint, sensors and telephony values disagree — not because of any deliberate anti-cheat. Coherence fixes those compatibility refusals.

**Boundary:** this is for compatibility with offline/single-player titles and ordinary apps. It is not for defeating competitive anti-cheat, integrity checks or licence enforcement. Respect each title's terms.

## Inspect the current identity (read-only)

```powershell
$adb = 'C:\LDPlayer\LDPlayer9\adb.exe'
$props = 'ro.product.model','ro.product.brand','ro.product.manufacturer',
         'ro.build.fingerprint','ro.build.version.release','ro.build.version.sdk',
         'ro.sf.lcd_density','gsm.sim.operator.alpha','gsm.operator.alpha'
foreach ($p in $props) {
  "{0,-32} {1}" -f $p, ((& $adb shell getprop $p | Out-String).Trim())
}
```

Or run the shipped helper:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\profile-check.ps1
```

## Coherence rules

| Rule | Why |
|---|---|
| Model, brand and manufacturer belong to the same real device family | Mismatches trip basic compatibility checks |
| Fingerprint matches the reported Android version and build ID | Inconsistent fingerprints look like a broken/tampered image |
| Screen density and resolution match what the app sees | Wrong DPI causes layout failures and "unsupported device" screens |
| Locale/timezone consistent with telephony | Some regional apps gate on this |
| Keep one profile per instance | Changing identity mid-session breaks app data association |

## Change identity only through LDPlayer's own settings

LDPlayer exposes device model, brand, IMEI/IMSI, MAC and Android version in the instance settings (gear → device / property settings); they persist in `vms\config\leidian0.config`. Prefer that to ad-hoc `setprop` writes, which are lost on reboot and create incoherence.

```powershell
# Verify what the instance config currently declares
Get-Content 'C:\LDPlayer\LDPlayer9\vms\config\leidian0.config' -Raw | ConvertFrom-Json |
  Select-Object 'propertySettings.phoneModel','propertySettings.phoneManufacturer',
                'propertySettings.phoneIMEI','propertySettings.phoneAndroidId'
```

After changing a device profile:

```powershell
& 'C:\LDPlayer\LDPlayer9\ldconsole.exe' reboot --index 0
Start-Sleep -Seconds 30
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\profile-check.ps1
```

## Sensors / input capabilities

```powershell
& 'C:\LDPlayer\LDPlayer9\adb.exe' shell dumpsys sensorservice | Select-Object -First 40
```

Titles that expect an accelerometer/gyroscope need those sensors enabled in LDPlayer's settings; otherwise the app sees a missing-sensor device. Enable only what the title actually uses.

## Failure modes

| Symptom | Fix |
|---|---|
| "Unsupported device" but app is compatible | Align model/fingerprint/density in instance settings, then reboot |
| App reads wrong region/timezone | Set guest timezone/locale consistently in settings |
| Identity resets after update | Update re-images `data.vmdk` — re-apply the instance profile |
| Title still refuses to run | It is enforcing a policy; stop there — do not escalate to anti-cheat evasion |

**Next:** [19 — Input & controls](19-input-and-controls.md)
