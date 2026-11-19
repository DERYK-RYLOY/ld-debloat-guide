# 16 — Storage & I/O

## Objective

Keep VM disk I/O on fast storage and avoid filesystem-level waste. No OS-level tweaks, no defragmenting an SSD.

## Locate the disks

```powershell
$LD = 'C:\LDPlayer\LDPlayer9'
Get-Item "$LD\system.vmdk","$LD\data.vmdk","$LD\data-3G.vmdk" |
  Select-Object Name, Length, LastWriteTime
Get-ChildItem "$LD\vms\leidian0" -File | Select-Object Name, Length
```

`system.vmdk` is the read-only Android system image; `data.vmdk` holds apps and settings; `sdcard.vmdk` holds shared storage.

## Verify the volume type and free space

```powershell
Get-Volume C | Select-Object DriveLetter, FileSystem, HealthStatus, Size, SizeRemaining
Get-PhysicalDisk | Select-Object FriendlyName, MediaType, HealthStatus
```

Keep at least 15–20% free on the volume holding the VMs — sparse disks grow over time.

## Sparse-file check (read-only)

```powershell
fsutil sparse queryflag 'C:\LDPlayer\LDPlayer9\data.vmdk'
fsutil sparse queryflag 'C:\LDPlayer\LDPlayer9\vms\leidian0\data.vmdk'
```

Sparse files report logical size much larger than allocated size. That is normal and desirable — do not "compact" them by copying with tools that expand sparse data.

## Vault growth

```powershell
Get-ChildItem 'C:\LDPlayer\vault' -Recurse -File |
  Measure-Object Length -Sum |
  Select-Object Count, @{n='GB';e={[math]::Round($_.Sum/1GB,2)}}
```

The offline installer alone is ~800 MB per vault run. Keep the latest vault until one clean update cycle has passed, then remove older ones ([13](guide/13-maintenance.md)).

## Rules

- Do not move a running instance's disks — stop the emulator first.
- Do not defragment an SSD; TRIM is handled by Windows.
- Do not edit `.vmdk` headers by hand; the VMDK descriptor is structure-sensitive.
- If the volume is HDD, relocating the whole `C:\LDPlayer` tree to an SSD is the single largest I/O win.

## Failure modes

| Symptom | Fix |
|---|---|
| Long boots, high disk queue | Move install to SSD; check free space |
| `InvalidMedium` after a copy | Copying expanded a sparse disk incorrectly — restore from vault |
| Vault consuming GBs | Prune old vault runs after verifying a clean update cycle |

**Next:** [17 — App compatibility](17-app-compatibility.md)
