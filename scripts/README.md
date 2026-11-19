# scripts/

PowerShell files deployed to `C:\LDPlayer\` by [guide/01](../guide/01-install-toolkit.md). Shipped verbatim; edit `$LD_ROOT` only when auto-detection fails.

| File | Run |
|---|---|
| `reapply-debloat.ps1` | After any update or FAIL; supports `-Silent` for the logon task |
| `clean-launch.ps1` | Every launch instead of the stock shortcut |
| `android-refresh.ps1` | With the emulator attached and ADB debugging ON — Lawnchair HOME, Private DNS, LD packages |
| `verify-debloat.ps1` | Read-only Windows audit; exit code = number of FAILs |
| `verify-android.ps1` | Read-only Android audit; exit code = number of FAILs |
| `perf-baseline.ps1` | Read-only performance snapshot for A/B measurement ([14](../guide/14-performance-baseline.md)) |
| `profile-check.ps1` | Read-only guest identity/network/package audit ([18](../guide/18-device-identity.md)) |

The last two are optional helpers: copy them to `C:\LDPlayer\` when working through the advanced capability guides. They never modify state.

## Contract

- **Idempotent:** any number of runs converge to the same state.
- **Vault-based:** everything moved goes to `C:\LDPlayer\vault\<timestamp>\`; nothing is deleted.
- **Self-elevating:** mutating scripts request administrator rights; verifiers should be started elevated.
- **Order-independent:** each script re-checks state before acting.

## Notes

- The sweep intentionally vaults `dnrepairer.exe` and `LDPlayer_<build>.exe` (the recovery path). Restore from the vault when a repair is needed — see [guide/03](../guide/03-vault-bloat.md).
- `verify-debloat.ps1` asserts those two are absent, consistent with the sweep.
- `verify-android.ps1` checks Lawnchair, Private DNS, HOME, LD packages — no root/other APKs are required.
- `dynamic-key.xml` is preserved for smart-keymap functionality.
