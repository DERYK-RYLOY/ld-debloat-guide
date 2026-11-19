# Troubleshooting

Failure → cause → exact fix. Applies to the Windows-side sweep, the scheduled enforcement, and the in-guest layer.

## Toolkit / install

| Symptom | Cause | Fix |
|---|---|---|
| `ERROR: no LDPlayer install with ldconsole.exe found` | Non-standard install path | Set `$LD_ROOT` at the top of `reapply-debloat.ps1` |
| Scheduled task `LastTaskResult` ≠ 0 | Script uses `-Silent` but the copied script lacks the parameter | Re-copy `scripts/reapply-debloat.ps1`; it ships with `param([switch]$Silent)` |
| Script parse error | Line-ending/encoding damage | Re-copy from `scripts/` |
| "Access is denied" on move | Not elevated | Run elevated; all mutating scripts self-elevate |

## Bloat / vault

| Symptom | Cause | Fix |
|---|---|---|
| Bloat returns after launch | Launch-time re-download | Launch via `clean-launch.ps1` (75 s watcher) or re-run `reapply-debloat.ps1` |
| Bloat returns after update | Update re-ships its own runtime | Logon task re-applies; run `verify-debloat.ps1` to confirm |
| Repair tool / installer missing when needed | Sweep vaulted them by design | Restore from vault ([guide/03](guide/03-vault-bloat.md)), repair, then re-run reapply |
| Missing file after vault | Wrong vault folder | Vault layout mirrors source paths; search `C:\LDPlayer\vault\*\<filename>` |

## Cache / ACL

| Symptom | Cause | Fix |
|---|---|---|
| Write into `%APPDATA%\XuanZhi9\cache` succeeds | Deny ACE missing/removed | Run `reapply-debloat.ps1` as administrator |
| Cannot read/change ACL | Not elevated | Run elevated |
| Cache path not found | Different vendor folder | Set `$cache` to the actual path in the script |

## Timestamps / service

| Symptom | Cause | Fix |
|---|---|---|
| Update check keeps offering builds | `nextCheckupdateTime` re-armed | Re-run `reapply-debloat.ps1` |
| Service back to Automatic | Update re-registered it | Re-run `reapply-debloat.ps1`; verify `Stopped / Disabled` |
| Config JSON parse error | File read mid-write | Wait for LDPlayer to exit; re-run |

## Networking

| Symptom | Cause | Fix |
|---|---|---|
| Hosts block duplicated | Manual append without checking the fence marker | Keep exactly one `Begin`/`End` pair |
| Online repair cannot fetch payloads | Hosts fence blocks LDPlayer CDN | Temporarily remove the marked block, repair, then reapply to restore it |
| Firewall rule points to a vaulted file | Expected after sweep | Inert; re-appears when file restored |

## VM / guest

| Symptom | Cause | Fix |
|---|---|---|
| Boot wedges at the same second twice | Guest RAM too low | Raise `RAMSize` to 3072 with the emulator stopped; retest |
| Host stutters / guest slow | Guest reservation too high | Lower RAM by 512 MB; `ldconsole modify --index 0 --cpu 3` |
| `VERR_*`, "not responding" | `leidian.vbox` edited while VM running | Stop the emulator, edit, relaunch; read `vms\leidian0\Logs\VBox.log` |
| `Failed to get COM interface (InvalidVirtualBox)` | VirtualBox layer missing/unregistered | Restore offline installer from vault and run it; reapply afterwards |
| `Invalid virtual disk (InvalidMedium)` | VM data disk destroyed (0 bytes) | Rebuild the instance from a clean install and restore user apps |
| `adb devices` empty | ADB debugging OFF in guest | LDPlayer → gear → Other → ADB debugging: ON |
| ADB off again | Update/fresh instance reset it | Re-enable after every update |
| HOME resets to LD launcher | Guest re-imaged | Re-run `android-refresh.ps1` |
| `su: not found` | Magisk boot patch missing | Magisk → Install → Direct install → Reboot |

## Verifiers

| Output | Meaning |
|---|---|
| `RESULT: ALL CHECKS PASSED`, exit 0 | All Windows-side invariants hold |
| `RESULT: N problem(s) found`, exit N | Read each `[FAIL]`; each names one invariant — re-run reapply |
| `RESULT: ALL ANDROID CHECKS PASSED` | In-guest state holds |
| `SKIP: no emulator attached` | Start the emulator; re-run |

## Escalation data to collect

```powershell
Get-Content 'C:\LDPlayer\reapply-log.txt' -Tail 40
Get-Content 'C:\LDPlayer\LDPlayer9\vms\leidian0\Logs\VBox.log' -Tail 60
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\verify-debloat.ps1
```
