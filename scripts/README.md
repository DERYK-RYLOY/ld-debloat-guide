# LD Debloat Guide — scripts

The five scripts referenced throughout the guide, as plain files. Works for **any LDPlayer install in the usual locations** (`C:\LDPlayer\LDPlayer*`); if yours lives elsewhere, set `$LD_ROOT` in `reapply-debloat.ps1` to the folder that contains `ldconsole.exe`.

| File | What it does | Run it |
|---|---|---|
| `reapply-debloat.ps1` | Re-applies the whole debloat (vault bloat, seal cache, re-pin pins, disable service, ensure hosts + firewall). Self-elevates. Idempotent. | After any update, any time something looks off |
| `clean-launch.ps1` | Debloat → launch LDPlayer → detached watcher sweeps ~75 s later | Instead of the stock shortcut, every launch |
| `android-refresh.ps1` | Inside-Android re-apply over ADB: LD packages disabled, Private DNS, Lawnchair HOME | When the emulator is running |
| `verify-debloat.ps1` | Read-only audit (Windows side). Exit code = number of FAILs | After any update |
| `verify-android.ps1` | Read-only audit (Android side). Exit code = number of FAILs | After any update, emulator running |

## Install (two minutes)

1. Copy these five files to `C:\LDPlayer\` (create the folder if it does not exist).
2. Right-click `reapply-debloat.ps1` → Run with PowerShell *as administrator*.
3. To launch: double-click `clean-launch.ps1` (or make it a shortcut and put it on your desktop).

Nothing is deleted by any script; every removed file is moved into `C:\LDPlayer\vault\`.
No file is modified other than LDPlayer's own config files plus one marked block in `drivers\etc\hosts`.

## Requirements

- Windows PowerShell 5.1+ (default on Windows 10/11)
- Administrator rights for reapply; the Android scripts need the emulator running with **ADB debugging ON**
- Tested against LDPlayer 9.x; graceful-skip behavior where a key/check does not exist in your version
