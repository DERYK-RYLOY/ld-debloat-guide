# 11 — Verify (Windows)

## Objective

Read-only audit of the Windows side. Exit code equals the number of FAILs.

## Run

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\verify-debloat.ps1
"exit=$LASTEXITCODE"
```

Must be elevated for the firewall/ACL checks to be meaningful.

## Checks performed

- `ldplayerpartner.exe`, `ldplayerpartner2.exe`, `bugreport.exe` absent
- `dnrepairer.exe` absent and no `LDPlayer_*.exe` present
- `upload\` telemetry SDK absent; partner log absent
- `cpi.data` / `ld_launcher` intercept feed absent
- `recommendConfigs` holds only `dynamic-key.xml`
- Ad cache exists, empty, and deny-write sealed
- `reportPCInfoTime`, `adLoadtime`, `nextCheckupdateTime` pinned
- `RAMSize="3072"` in the VM definition
- Telemetry service disabled
- Marked hosts fence present; at least one `LDPlayerBlock-*` rule enabled

## Expected output

```text
LDPlayer: C:\LDPlayer\LDPlayer9
version: 9.5.45.0
[PASS] ldplayerpartner.exe absent
[PASS] dnrepairer.exe absent
[PASS] ad cache sealed (write denied)
...
RESULT: ALL CHECKS PASSED
exit=0
```

A `FAIL` line names the exact invariant that broke. Typically the fix is one more `reapply-debloat.ps1` run.

## Why the repair tool is expected absent

The sweep vaults `dnrepairer.exe` and `LDPlayer_*.exe`; the verifier asserts that state. See [03](03-vault-bloat.md) for the restore procedure when a repair is needed.

**Next:** [12 — Android side](12-android.md)
