# 06 — Tune guest CPU / RAM

## Objective

Keep the guest inside the host's memory surplus. Reference profile: **3 vCPU / 3072 MB**.

## Rule

- Guest RAM ≤ ~40% of host RAM during normal use, never >50%.
- 8 GB host → 2048–4096 MB; 3072 MB is the reference.
- Reduce by 512 MB and re-test if cold boots wedge at the same point twice.

## CPU (official CLI)

```powershell
& 'C:\LDPlayer\LDPlayer9\ldconsole.exe' modify --index 0 --cpu 3
& 'C:\LDPlayer\LDPlayer9\ldconsole.exe' list2   # confirm cpu=3 for index 0
```

The master script re-applies this on every run.

## RAM (VM definition)

```powershell
$ld = 'C:\LDPlayer\LDPlayer9'
Get-Process dnplayer -ErrorAction SilentlyContinue | Stop-Process -Force   # must be stopped
$vbox = "$ld\vms\leidian0\leidian.vbox"
(Get-Content $vbox -Raw) -match 'RAMSize="(\d+)"' | Out-Null; $Matches[1]
```

To change, edit the `RAMSize` value on the `Memory` line with the emulator closed:

```powershell
$vbox = 'C:\LDPlayer\LDPlayer9\vms\leidian0\leidian.vbox'
(Get-Content $vbox -Raw) -replace 'RAMSize="\d+"','RAMSize="3072"' |
  Set-Content $vbox -Encoding UTF8
```

LDPlayer rewrites this file on launch; do not hand-edit while running.

## Verify after a boot

```powershell
Get-Content 'C:\LDPlayer\LDPlayer9\vms\leidian0\Logs\VBox.log' |
  Select-String 'CPUs:|RAMSize|vboxguest: Successfully loaded'
```

## Failure modes

| Symptom | Fix |
|---|---|
| Boots freeze at the same second | Guest RAM too low for first boot — raise to 3072 and retest |
| Host stutters/thermal | Lower guest RAM by 512 MB; close host heavy apps |
| `ldconsole modify` no effect | Instance index wrong — check `ldconsole list2` |

**Next:** [07 — Disable the telemetry service](07-disable-service.md)
