# 22 — Benchmark & verify

## Objective

Prove the debloat and tuning produced a measurable improvement, and verify nothing regressed.

## 1. Repeat the baseline

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\perf-baseline.ps1 |
  Tee-Object "C:\LDPlayer\baseline-after-$(Get-Date -Format yyyyMMdd-HHmm).txt"
```

## 2. Cold boot timing

```powershell
$sw = [Diagnostics.Stopwatch]::StartNew()
& 'C:\LDPlayer\LDPlayer9\ldconsole.exe' launch --index 0
do { Start-Sleep -Seconds 2; $dev = (& 'C:\LDPlayer\LDPlayer9\adb.exe' devices | Out-String) }
until ($dev -match 'emulator-\d+\s+device')
$sw.Stop()
"cold boot: {0:N1}s" -f $sw.Elapsed.TotalSeconds
```

## 3. Host load under a fixed workload

```powershell
Get-Counter '\Processor(_Total)\% Processor Time','\Memory\Available MBytes','\LogicalDisk(C:)\Disk Reads/sec' `
  -SampleInterval 1 -MaxSamples 20 |
  Select-Object -ExpandProperty CounterSamples |
  Group-Object Path | ForEach-Object {
    "{0,-60} avg={1:N1}" -f $_.Name, (($_.Group | Measure-Object CookedValue -Average).Average)
  }
```

Run the same in-game scene before and after; compare averages, not peaks.

## 4. Correctness audits

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\verify-debloat.ps1
"windows exit=$LASTEXITCODE"
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\verify-android.ps1
"android exit=$LASTEXITCODE"
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\profile-check.ps1
```

## 5. Acceptance matrix

| Item | Pass condition |
|---|---|
| `verify-debloat.ps1` | `ALL CHECKS PASSED`, exit 0 |
| `verify-android.ps1` | `ALL ANDROID CHECKS PASSED`, exit 0 |
| Cold boot | Equal to or better than baseline |
| Host CPU under fixed scene | Equal to or lower than baseline |
| Title compatibility | All target titles launch; no identity error screens |
| Keymap | Full session replay works |
| Update survival | Re-run both verifiers after one LDPlayer update |

## Failure modes

| Symptom | Fix |
|---|---|
| Boot slower after tuning | Revert the last variable (renderer, RAM, resolution) and re-measure |
| CPU higher after "optimisation" | Software renderer fallback — check [15](15-renderer-and-gpu.md) |
| Verifier FAIL after update | Re-run `reapply-debloat.ps1`; check scheduled task result |

**Next:** [Command index](../reference/commands.md) · [Troubleshooting](../reference/troubleshooting.md)
