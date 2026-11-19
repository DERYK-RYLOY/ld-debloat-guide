# 02 — Inventory & baseline

## Objective

Record exactly what this machine runs before making changes. All commands are read-only.

## Install identity

```powershell
$LD = 'C:\LDPlayer\LDPlayer9'
(Get-Item "$LD\dnplayer.exe").VersionInfo.ProductVersion
& "$LD\ldconsole.exe" list
& "$LD\ldconsole.exe" list2
```

## Service state

```powershell
foreach ($s in 'LDPlayerENSvr','LDPlayerENSvc','LDPlayerServiceEN') {
  Get-Service $s -ErrorAction SilentlyContinue | Select-Object Name, Status, StartType
}
```

## Config files

```powershell
Get-Content "$LD\vms\config\leidians.config" -Raw | ConvertFrom-Json |
  Select-Object reportPCInfoTime, adLoadtime, nextCheckupdateTime, isSSD, strp
Get-Content "$LD\vms\config\leidian0.config" -Raw
```

## Guest resources

```powershell
Get-Content "$LD\vms\leidian0\leidian.vbox" |
  Select-String 'RAMSize|CPU count'
Get-CimInstance Win32_OperatingSystem |
  Select-Object @{n='HostRAM_GB';e={[math]::Round($_.TotalVisibleMemorySize/1MB,1)}}
```

## Bloat inventory (what should be gone afterwards)

```powershell
$bloat = @('ldplayerpartner.exe','ldplayerpartner2.exe','bugreport.exe','dnrepairer.exe','upload')
foreach ($b in $bloat) { '{0,-26} {1}' -f $b, (Test-Path "$LD\$b") }
Get-ChildItem "$LD" -Filter 'LDPlayer_*.exe' | Select-Object Name, Length
Get-ChildItem "$LD\vms\recommendConfigs" -Force -ErrorAction SilentlyContinue | Select-Object Name, Length
```

## Network baseline

```powershell
Get-Content 'C:\Windows\System32\drivers\etc\hosts' -Raw |
  Select-String 'LDPlayer-Debloat-Block-Begin'
Get-NetFirewallRule -DisplayName 'LDPlayerBlock-*' -ErrorAction SilentlyContinue |
  Select-Object DisplayName, Enabled
```

## Failure modes

| Output | Meaning |
|---|---|
| `list2` shows no instances | Create an instance in LDPlayer first; index 0 is assumed everywhere |
| `leidian.vbox` missing | Start the emulator once so LDPlayer generates the VM definition |
| hosts `Select-String` empty | No fence yet — expected; step 08 adds it |

**Next:** [03 — Vault classic bloat](03-vault-bloat.md)
