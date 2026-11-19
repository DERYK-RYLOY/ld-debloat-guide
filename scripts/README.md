# scripts/

The five PowerShell files deployed to `C:\LDPlayer\` by [guide/01](../guide/01-install-toolkit.md). Shipped verbatim; edit `$LD_ROOT` only when auto-detection fails.

| File | Run |
|---|---|
| `reapply-debloat.ps1` | After any update or FAIL; supports `-Silent` for the logon task |
| `clean-launch.ps1` | Every launch instead of the stock shortcut |
| `android-refresh.ps1` | With the emulator attached and ADB debugging ON |
| `verify-debloat.ps1` | Read-only Windows audit; exit code = number of FAILs |
| `verify-android.ps1` | Read-only Android audit; exit code = number of FAILs |

## Contract

- **Idempotent:** any number of runs converge to the same state.
- **Vault-based:** everything moved goes to `C:\LDPlayer\vault\<timestamp>\`; nothing is deleted.
- **Self-elevating:** mutating scripts request administrator rights; verifiers should be started elevated.
- **Order-independent:** each script re-checks state before acting.

## Notes

- The sweep intentionally vaults `dnrepairer.exe` and `LDPlayer_<build>.exe` (the recovery path). Restore from the vault when a repair is needed — see [guide/03](../guide/03-vault-bloat.md).
- `verify-debloat.ps1` asserts those two are absent, consistent with the sweep.
- `dynamic-key.xml` is preserved for smart-keymap functionality.
