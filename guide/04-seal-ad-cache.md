# 04 — Seal the ad cache

## Objective

Empty the ad payload cache and prevent LDPlayer from re-populating it, with exactly one ACL change.

## What the script does

1. Finds the cache (`%APPDATA%\XuanZhi9\cache`, with fallbacks for other build names).
2. Moves its contents into `vault\<run>\adcache`.
3. Adds one inherited **Deny Write for Everyone** ACE; no other ACL entry is touched.

## Apply (part of the master script)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\reapply-debloat.ps1 -Silent
```

Manual equivalent when isolating the step:

```powershell
$cache = Join-Path $env:APPDATA 'XuanZhi9\cache'
$pending = Get-ChildItem $cache -Force -ErrorAction SilentlyContinue
if ($pending) {
  $dest = 'C:\LDPlayer\vault\adcache'; New-Item -ItemType Directory -Force -Path $dest | Out-Null
  $pending | Move-Item -Destination $dest -Force
}
icacls $cache /remove:d Everyone 2>&1 | Out-Null
icacls $cache /deny 'Everyone:(OI)(CI)W' 2>&1 | Out-Null
```

## Verify

```powershell
$cache = Join-Path $env:APPDATA 'XuanZhi9\cache'
(Get-ChildItem $cache -Force | Measure-Object).Count          # 0
(Get-Acl $cache).Access |
  Where-Object { $_.AccessControlType -eq 'Deny' -and $_.FileSystemRights -match 'Write' } |
  Select-Object IdentityReference, FileSystemRights, IsInherited
```

Write test (must fail):

```powershell
[IO.File]::WriteAllText((Join-Path $cache 'probe.txt'),'x')   # UnauthorizedAccessException
```

## Failure modes

| Symptom | Fix |
|---|---|
| Write test succeeds | Not elevated, or ACE removed — re-run as administrator |
| Cannot read ACL | Run elevated |
| Cache path absent | Build uses a different vendor folder — set `$cache` explicitly |

## Rollback

```powershell
icacls $cache /remove:d Everyone
```

**Next:** [05 — Pin telemetry & update timestamps](05-pin-telemetry.md)
