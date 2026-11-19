# 05 — Pin telemetry & update timestamps

## Objective

Stop `leidians.config` from re-arming telemetry reports and update checks after each update.

## Keys

| Key | Pinned value |
|---|---|
| `reportPCInfoTime` | `20990101` |
| `adLoadtime` | `4102444800` (2100-01-01) |
| `nextCheckupdateTime` | `4102444800` |
| `noiceUserRed` (when present) | `false` |

Missing keys are skipped, never invented — builds differ.

## Apply (part of the master script)

```powershell
$cfgPath = 'C:\LDPlayer\LDPlayer9\vms\config\leidians.config'
$cfg = Get-Content $cfgPath -Raw | ConvertFrom-Json
foreach ($k in 'reportPCInfoTime','adLoadtime','nextCheckupdateTime') {
  if ($cfg.PSObject.Properties.Name -contains $k) {
    $cfg.$k = if ($k -eq 'reportPCInfoTime') { '20990101' } else { 4102444800 }
  }
}
if ($cfg.PSObject.Properties.Name -contains 'noiceUserRed') { $cfg.noiceUserRed = $false }
[IO.File]::WriteAllText($cfgPath, ($cfg | ConvertTo-Json -Depth 5), (New-Object Text.ASCIIEncoding))
```

The shipped script logs `leidians.config pins re-applied (present keys only)`.

## Verify

```powershell
(Get-Content 'C:\LDPlayer\LDPlayer9\vms\config\leidians.config' -Raw | ConvertFrom-Json) |
  Select-Object reportPCInfoTime, adLoadtime, nextCheckupdateTime
```

Expected: `20990101`, `4102444800`, `4102444800`.

## Failure modes

| Symptom | Fix |
|---|---|
| `ConvertFrom-Json` throws | LDPlayer rewrote the file mid-read; wait for it to exit, re-run |
| Values reset after update | Expected — the logon task and the master script re-pin |
| Key absent | Correct for that build; verifier accepts absence |

## Rollback

Restore `leidians.config` from the baseline copy captured in step 02.

**Next:** [06 — Tune guest CPU/RAM](06-tune-guest.md)
