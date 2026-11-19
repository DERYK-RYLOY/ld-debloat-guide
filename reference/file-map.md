# File map

Sources and destinations for every item the toolkit moves. All moves are into `C:\LDPlayer\vault\<timestamp>\` with mirrored subfolders.

## Install root (`LDPlayer9\`)

| Item | Classification | Vault subfolder |
|---|---|---|
| `ldplayerpartner.exe`, `ldplayerpartner2.exe` | Launcher ads | `LDPlayer9\` |
| `bugreport.exe` | Telemetry reporter | `LDPlayer9\` |
| `log\ldpartner.log` | Partner report log | `log\` |
| `dnrepairer.exe` | Built-in repair tool — recovery path | `LDPlayer9\` |
| `LDPlayer_<build>.exe` | Offline installer payload (~800 MB) — recovery path | `LDPlayer9\` |
| `upload\` | Huawei OBS crash SDK | `upload\` |
| `ldmutiplayer\bugreport.exe` | Second reporter | `ldmutiplayer\` |

## User data

| Item | Location | Vault subfolder |
|---|---|---|
| `ld_launcher` | `Documents\XuanZhi9\Applications\` | `intercept\` |
| `cpi.data` | same | `intercept\` |
| `appInfo.txt` | same | `intercept\` |
| hex-named fetch stamps | same | `intercept\` |
| ad payloads | `%APPDATA%\XuanZhi9\cache\` | `adcache\` |
| `dir_*.dir`, `package_configs_1005*` | `LDPlayer9\vms\recommendConfigs\` | `recommendConfigs\` |

## Deliberately preserved

| Item | Reason |
|---|---|
| `vms\recommendConfigs\dynamic-key.xml` | Smart-keymap data |
| `vms\config\leidian0.config` | Instance identity (IMEI, model, shared folders) |
| `vms\leidian0\leidian.vbox` | VM definition; edited only via CPU/RAM steps |
| `system.vmdk`, `data.vmdk` | Guest disks |
| All APKs / user files inside the guest | Out of scope |

## Vendor folder variants

Scripts try, in order: `XuanZhi9`, `XuanZhi`, `Letu` under both `Documents\...\Applications` and `%APPDATA%\...\cache`. Missing paths are skipped. If a build uses another name, extend the candidate arrays in `reapply-debloat.ps1`.
