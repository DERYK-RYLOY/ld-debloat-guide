# 14 — Performance baseline

## Objective

Capture a reproducible snapshot before tuning anything. Every later performance claim is measured against this baseline.

## Run the baseline script

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\perf-baseline.ps1
```

It is read-only: version, instance config, vCPU/RAM, hosts/CPU/GPU, service states, telemetry pins, and the tail of `VBox.log`. Redirect to a file for A/B comparisons:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\perf-baseline.ps1 |
  Tee-Object "C:\LDPlayer\baseline-$(Get-Date -Format yyyyMMdd-HHmm).txt"
```

## Manual snapshot

```powershell
$LD = 'C:\LDPlayer\LDPlayer9'
(Get-Item "$LD\dnplayer.exe").VersionInfo.ProductVersion
& "$LD\ldconsole.exe" list2
Get-Content "$LD\device.ini"
Get-Content "$LD\vms\leidian0\leidian.vbox" | Select-String 'CPU count|RAMSize|MACAddress'
Get-CimInstance Win32_Processor | Select-Object Name, NumberOfLogicalProcessors
Get-CimInstance Win32_VideoController | Select-Object Name, DriverVersion, AdapterRAM
Get-CimInstance Win32_OperatingSystem |
  Select-Object @{n='TotalRAM_GB';e={[math]::Round($_.TotalVisibleMemorySize/1MB,1)}},
                @{n='FreeRAM_GB';e={[math]::Round($_.FreePhysicalMemory/1MB,1)}}
```

## Host load sample (10 s)

```powershell
Get-Counter '\Processor(_Total)\% Processor Time','\Memory\Available MBytes' `
  -SampleInterval 1 -MaxSamples 10 |
  Select-Object -ExpandProperty CounterSamples |
  Group-Object Path | ForEach-Object {
    "{0}  avg={1:N1}" -f $_.Name, (($_.Group | Measure-Object CookedValue -Average).Average)
  }
```

## Guest-side identity/resource snapshot

```powershell
$adb = 'C:\LDPlayer\LDPlayer9\adb.exe'
& $adb shell getprop ro.build.version.release
& $adb shell getprop ro.product.cpu.abilist
& $adb shell dumpsys meminfo | Select-Object -First 12
```

## What to record in a per-title profile

| Field | Source |
|---|---|
| Cold boot time | wall clock from `ldconsole launch` to `adb devices` |
| Guest CPU/RAM | `leidian.vbox` |
| Renderer / resolution / FPS | LDPlayer settings + `VBox.log` |
| Host CPU/RAM/GPU | `perf-baseline.ps1` |
| In-title FPS | title's own FPS counter or overlay |

## Rules

- Change **one** variable per measurement.
- Reboot the guest between runs; cold boot differs from warm resume.
- Keep the baseline file until the final verification ([22](22-benchmark-and-verify.md)).

**Next:** [15 — Renderer & GPU](15-renderer-and-gpu.md)
