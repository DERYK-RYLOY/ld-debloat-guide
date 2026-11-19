# LD Debloat Guide — Advanced Edition

A command-driven playbook for turning a stock LDPlayer 9 install into a lean, fast, self-healing Android environment. Every step is copy-paste PowerShell with verification and rollback. No filler, no screenshots, no beginner narrative.

**Target:** LDPlayer 9.x on Windows 10/11 · **Method:** vault, never delete · **Enforcement:** logon task + launch-time sweep · **Verification:** `verify-debloat.ps1` + `verify-android.ps1`.

## What this playbook covers

1. **Removal** — every ad, telemetry, reporter, intercept and recommendation payload the install ships with ([03](guide/03-vault-bloat.md), [09](guide/09-deep-sweep.md))
2. **Prevention** — cache seal, timestamp pins, service disable, hosts + firewall fences ([04](guide/04-seal-ad-cache.md) → [08](guide/08-network-blocks.md))
3. **Persistence** — hidden logon task and launch-time watcher ([10](guide/10-enforce-logon.md), [13](guide/13-maintenance.md))
4. **Capability** — performance profiling, renderer/GPU selection, storage I/O, ABI/GMS compatibility, input, network, per-title profiles ([14](guide/14-performance-baseline.md) → [21](guide/21-per-title-profiles.md))
5. **Verification** — read-only audits and A/B measurement ([11](guide/11-verify-windows.md), [12](guide/12-android.md), [22](guide/22-benchmark-and-verify.md))

## Steps

| # | Guide | Scope |
|---|---|---|
| 00 | [Preflight](guide/00-preflight.md) | install path, elevation, baseline |
| 01 | [Install the toolkit](guide/01-install-toolkit.md) | five scripts |
| 02 | [Inventory](guide/02-inventory.md) | version, instances, config, services |
| 03 | [Vault classic bloat](guide/03-vault-bloat.md) | ads, reporters, recovery files |
| 04 | [Seal the ad cache](guide/04-seal-ad-cache.md) | deny-write ACE |
| 05 | [Pin telemetry](guide/05-pin-telemetry.md) | `leidians.config` |
| 06 | [Tune guest CPU/RAM](guide/06-tune-guest.md) | 3 vCPU / 3072 MB reference |
| 07 | [Disable telemetry service](guide/07-disable-service.md) | `LDPlayerENSvr` |
| 08 | [Hosts + firewall](guide/08-network-blocks.md) | two egress layers |
| 09 | [Deep sweep](guide/09-deep-sweep.md) | second telemetry stack, feeds |
| 10 | [Enforce at logon](guide/10-enforce-logon.md) | scheduled task |
| 11 | [Verify (Windows)](guide/11-verify-windows.md) | read-only audit |
| 12 | [Android side — Lawnchair](guide/12-android.md) | ADB, HOME, DNS, LD packages |
| 13 | [Maintenance](guide/13-maintenance.md) | update cadence |
| **14** | [Performance baseline](guide/14-performance-baseline.md) | measure before tuning |
| **15** | [Renderer & GPU](guide/15-renderer-and-gpu.md) | OpenGL/DirectX/Vulkan, frame pacing |
| **16** | [Storage & I/O](guide/16-storage-io.md) | VMDK placement, disk cache |
| **17** | [App compatibility](guide/17-app-compatibility.md) | Android profile, ABI, GMS |
| **18** | [Device identity](guide/18-device-identity.md) | coherent guest profile for compatibility |
| **19** | [Input & controls](guide/19-input-and-controls.md) | keymap, gamepad, multi-touch |
| **20** | [Network & DNS](guide/20-network-and-dns.md) | ad-blocking without breaking apps |
| **21** | [Per-title profiles](guide/21-per-title-profiles.md) | game recipes |
| **22** | [Benchmark & verify](guide/22-benchmark-and-verify.md) | A/B measurement |

## Reference

[Command index](reference/commands.md) · [File map](reference/file-map.md) · [Config keys](reference/config-keys.md) · [Troubleshooting](reference/troubleshooting.md)

## Invariants

1. **Vault, never delete.** Every removed file is in `C:\LDPlayer\vault\<timestamp>\` with mirrored paths.
2. **Idempotent.** Re-running any step converges; nothing stacks.
3. **Recovery files are vaulted too.** `dnrepairer.exe` / `LDPlayer_<build>.exe` return from the vault when a repair is needed ([03](guide/03-vault-bloat.md)).
4. **Measure before concluding.** Baseline first ([14](guide/14-performance-baseline.md)); change one variable at a time.
5. **Application layer only.** No Windows servicing, Defender changes, or power-plan edits. One fenced hosts block and named firewall rules are the only host changes.
6. **Compatibility, not anti-cheat.** Device-identity work targets apps/games that misclassify emulators (typically offline/single-player titles). It is not for defeating competitive anti-cheat or integrity checks; respect each title's terms.

MIT — see `LICENSE`.
