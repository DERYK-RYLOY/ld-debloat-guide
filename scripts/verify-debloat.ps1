# verify-debloat.ps1 - READ-ONLY audit of the LDPlayer install. Prints PASS/FAIL per item.
# Exit code = number of FAILs. Works for any LDPlayer version in the usual locations.
$LD_ROOT = $null
foreach ($candidate in @('C:\LDPlayer\LDPlayer9','C:\LDPlayer\LDPlayer12','C:\LDPlayer\LDPlayer5','C:\LDPlayer\LDPlayer4','C:\LDPlayer\LDPlayer9x')) {
  if (Test-Path "$candidate\ldconsole.exe") { $LD_ROOT = $candidate; break }
}
if (-not $LD_ROOT) {
  $hit = Get-ChildItem 'C:\LDPlayer' -Directory -Force -ErrorAction SilentlyContinue | Where-Object { Test-Path (Join-Path $_.FullName 'ldconsole.exe') } | Select-Object -First 1
  if ($hit) { $LD_ROOT = $hit.FullName }
}
$fails = 0
function Report($l){ Write-Host $l }
function Verify($name, [scriptblock]$test){
  $ok = $false
  try { $ok = [bool](& $test) } catch { $ok = $false }
  if ($ok) { Report "[PASS] $name" } else { Report "[FAIL] $name"; $script:fails++ }
}

if (-not $LD_ROOT) { Report 'FAIL: LDPlayer install not found'; exit 2 }
Report "LDPlayer: $LD_ROOT"

$ver = (Get-Item "$LD_ROOT\dnplayer.exe" -ErrorAction SilentlyContinue).VersionInfo.ProductVersion
Report "version: $ver"

foreach ($bloat in @('ldplayerpartner.exe','ldplayerpartner2.exe','bugreport.exe','dnrepairer.exe')) {
  Verify "$bloat absent" { -not (Test-Path (Join-Path $LD_ROOT $bloat)) }
}
Get-ChildItem $LD_ROOT -Filter 'LDPlayer_*.exe' -ErrorAction SilentlyContinue | ForEach-Object { Verify "stub absent: $($_.Name)" { $false } }
Verify 'no Huawei OBS upload SDK (upload\)'      { -not (Test-Path "$LD_ROOT\upload") }
Verify 'partner log absent'                     { -not (Test-Path "$LD_ROOT\log\ldpartner.log") }

$appStore = $null
foreach ($cand in @("$env:USERPROFILE\Documents\XuanZhi9\Applications","$env:USERPROFILE\Documents\XuanZhi\Applications","$env:USERPROFILE\Documents\Letu\Applications")) {
  if ($cand -and (Test-Path $cand)) { $appStore = $cand; break }
}
Verify 'app-store ad feed absent (cpi.data)'    { $appStore -eq $null -or -not (Test-Path (Join-Path $appStore 'cpi.data')) }
Verify 'app-store intercept feed absent'        { $appStore -eq $null -or -not (Test-Path (Join-Path $appStore 'ld_launcher')) }

$rec = "$LD_ROOT\vms\recommendConfigs"
$recLeft = if (Test-Path $rec) { Get-ChildItem $rec -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne 'dynamic-key.xml' } } else { $null }
Verify 'recommendation/ad DB vaulted'           { -not $recLeft }

$cache = $null
foreach ($cand in @("$env:APPDATA\XuanZhi9\cache","$env:APPDATA\XuanZhi\cache","$env:APPDATA\Letu\cache")) {
  if (Test-Path $cand) { $cache = $cand; break }
}
Verify 'ad cache exists and is empty'           { $cache -and -not (Get-ChildItem $cache -Force -ErrorAction SilentlyContinue) }
Verify 'ad cache sealed (write denied)'         { $cache -and [bool]((Get-Acl $cache).Access | Where-Object { $_.AccessControlType -eq 'Deny' -and $_.IdentityReference -like '*Everyone*' -and $_.FileSystemRights.ToString() -like '*Write*' }) }

$cfgPath = "$LD_ROOT\vms\config\leidians.config"
if (Test-Path $cfgPath) {
  $cfg = Get-Content $cfgPath -Raw | ConvertFrom-Json
  Verify 'telemetry report pinned'                { ($cfg.reportPCInfoTime -eq '20990101') -or (-not $cfg.reportPCInfoTime) }
  Verify 'adLoadtime pinned to 2100'              { ($null -eq $cfg.adLoadtime) -or ($cfg.adLoadtime -ge 4102444800) }
  Verify 'update check pinned to 2100'            { ($null -eq $cfg.nextCheckupdateTime) -or ($cfg.nextCheckupdateTime -ge 4102444800) }
}
$vbox = Join-Path $LD_ROOT 'vms\leidian0\leidian.vbox'
if (Test-Path $vbox) {
  $v = Get-Content $vbox -Raw
  Verify 'RAM cap = 3072'                         { $v -match 'RAMSize="3072"' }
}

foreach ($svcName in @('LDPlayerENSvr','LDPlayerENSvc','LDPlayerServiceEN')) {
  $svc = Get-Service $svcName -ErrorAction SilentlyContinue
  if ($svc) { Verify "$svcName disabled" { $svc.StartType -eq 'Disabled' } }
}

Verify 'hosts block present'                      { (Get-Content 'C:\Windows\System32\drivers\etc\hosts' -Raw) -match 'LDPlayer-Debloat-Block-Begin' }
$rules = (Get-NetFirewallRule -DisplayName 'LDPlayerBlock-*' -ErrorAction SilentlyContinue).DisplayName
Verify 'firewall egress blocks present'           { ($rules | Measure-Object).Count -ge 1 }

if ($fails -eq 0) { Report 'RESULT: ALL CHECKS PASSED' } else { Report "RESULT: $fails problem(s) found" }
exit $fails
