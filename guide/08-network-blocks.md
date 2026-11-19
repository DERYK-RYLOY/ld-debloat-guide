# 08 — Hosts + firewall blocks

## Objective

Two independent egress layers: a marked hosts fence for known domains, and program-scoped firewall rules that survive domain rotation.

## Layer A — hosts fence

```powershell
$hosts = 'C:\Windows\System32\drivers\etc\hosts'
if (-not ((Get-Content $hosts -Raw) -match 'LDPlayer-Debloat-Block-Begin')) {
  $block = @'

# LDPlayer-Debloat-Block-Begin (LDPlayer ad/telemetry endpoints)
0.0.0.0 ldrescdn.com
0.0.0.0 res.ldrescdn.com
0.0.0.0 img.ldrescdn.com
0.0.0.0 tj.ldmnq.com
0.0.0.0 ad.ldmnq.com
0.0.0.0 ads.ldplayer.net
0.0.0.0 report.ldmnq.com
0.0.0.0 alog.ldmnq.com
0.0.0.0 data.ldplayer.net
0.0.0.0 res.ldplayer.net
# LDPlayer-Debloat-Block-End
'@
  [IO.File]::AppendAllText($hosts, $block, (New-Object Text.ASCIIEncoding))
}
```

Nothing outside the fences is modified. The master script performs this check-and-append automatically.

## Layer B — firewall rules

```powershell
$LD = 'C:\LDPlayer\LDPlayer9'
$rules = @{
  'LDPlayerBlock-ldplayerpartner'   = "$LD\ldplayerpartner.exe"
  'LDPlayerBlock-ldplayerpartner2'  = "$LD\ldplayerpartner2.exe"
  'LDPlayerBlock-dnrepairer'        = "$LD\dnrepairer.exe"
  'LDPlayerBlock-bugreport'         = "$LD\bugreport.exe"
  'LDPlayerBlock-ldplayerserviceEN' = "$LD\ldplayerserviceEN.exe"
  'LDPlayerBlock-ldupload'          = "$LD\upload\ldupload.exe"
}
foreach ($name in $rules.Keys) {
  if ((Test-Path $rules[$name]) -and -not (Get-NetFirewallRule -DisplayName $name -EA SilentlyContinue)) {
    New-NetFirewallRule -DisplayName $name -Direction Outbound -Action Block -Program $rules[$name] -Profile Any -Enabled True | Out-Null
  }
}
```

Rules are created only for executables that exist; they re-apply automatically after an update restores the same path.

## Verify

```powershell
Get-Content 'C:\Windows\System32\drivers\etc\hosts' -Raw |
  Select-String 'LDPlayer-Debloat-Block-Begin|LDPlayer-Debloat-Block-End'
Get-NetFirewallRule -DisplayName 'LDPlayerBlock-*' |
  Select-Object DisplayName, Enabled, Direction, Action
```

## Interaction with the offline repair

The hosts fence blocks LDPlayer's CDN. An online repair cannot fetch payloads until the fence is lifted:

```powershell
# temporary, only for an online repair
$fence = Select-String -Path 'C:\Windows\System32\drivers\etc\hosts' -Pattern 'LDPlayer-Debloat' | Select-Object -First 1
# edit the marked block out, repair, then re-run reapply-debloat.ps1 to restore it
```

## Failure modes

| Symptom | Fix |
|---|---|
| Access denied writing hosts | Run elevated |
| Duplicate fences | Only one block is allowed — remove extras manually |
| Rule points at a vaulted file | Expected; rule becomes inert until the file is restored |

**Next:** [09 — Deep sweep](09-deep-sweep.md)
