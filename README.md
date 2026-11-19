# LD Debloat Guide

Command-driven playbook for taking an LDPlayer 9 install from stock to a lean, self-healing state. Every step is a copy-paste PowerShell block with an explicit verification command and a rollback path. No narrative, no PDF, no hand-holding.

**Target:** LDPlayer 9.x on Windows 10/11 · **Method:** vault, never delete · **Enforcement:** logon task + launch-time sweep · **Verification:** two read-only audit scripts.

---

## Quickstart

```powershell
# 1. Install the five scripts into C:\LDPlayer\  (see guide/01)
# 2. Baseline first — see guide/02
& 'C:\LDPlayer\LDPlayer9\ldconsole.exe' list2
(Get-Item 'C:\LDPlayer\LDPlayer9\dnplayer.exe').VersionInfo.ProductVersion

# 3. Apply the full debloat (self-elevating, idempotent)
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\reapply-debloat.ps1

# 4. Audit — exit code 0 means clean
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\verify-debloat.ps1
```

## Steps

| # | Guide | Scope |
|---|---|---|
| 00 | [Preflight](guide/00-preflight.md) | install path, elevation, PowerShell, backup of config |
| 01 | [Install the toolkit](guide/01-install-toolkit.md) | place the five scripts, confirm detection |
| 02 | [Inventory & baseline](guide/02-inventory.md) | version, instances, config, services, free RAM |
| 03 | [Vault classic bloat](guide/03-vault-bloat.md) | partner, reporter, telemetry SDK, installer stub |
| 04 | [Seal the ad cache](guide/04-seal-ad-cache.md) | empty + one deny-write ACE |
| 05 | [Pin telemetry & update timestamps](guide/05-pin-telemetry.md) | `leidians.config` far-future pins |
| 06 | [Tune guest CPU/RAM](guide/06-tune-guest.md) | 3 vCPU / 3072 MB reference profile |
| 07 | [Disable the telemetry service](guide/07-disable-service.md) | `LDPlayerENSvr` and variants |
| 08 | [Hosts + firewall blocks](guide/08-network-blocks.md) | marked hosts fence + program-scoped egress rules |
| 09 | [Deep sweep](guide/09-deep-sweep.md) | upload SDK, second reporter, intercept feed, recommend DB |
| 10 | [Enforce at logon](guide/10-enforce-logon.md) | hidden scheduled task, `-Silent` |
| 11 | [Verify (Windows)](guide/11-verify-windows.md) | read-only audit, exit-code semantics |
| 12 | [Android side](guide/12-android.md) | ADB, in-guest packages, DNS, HOME |
| 13 | [Maintenance](guide/13-maintenance.md) | update cadence, re-verify, vault lifecycle |

## Reference

- [File map](reference/file-map.md) — what is moved, where it goes
- [Command index](reference/commands.md) — every command, one place
- [Troubleshooting](reference/troubleshooting.md) — failure → cause → fix

## Invariants

1. **Vault, never delete.** Everything removed is moved under `C:\LDPlayer\vault\` with mirrored layout.
2. **Idempotent.** Re-running any step converges to the same state; nothing stacks.
3. **Recovery files are vaulted too.** `dnrepairer.exe` and `LDPlayer_<build>.exe` are treated as bloat by the sweep. To use the launcher's **Fix** button or the offline installer later, restore them from the vault first ([troubleshooting](reference/troubleshooting.md)).
4. **Verify, don't assume.** Each step ends with a command whose output proves the state.
5. **Application layer only.** No Windows servicing tools, Defender changes, power-plan changes, or host OS modifications beyond one fenced hosts block and named firewall rules.

MIT — see `LICENSE`.
