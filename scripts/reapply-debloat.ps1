# reapply-debloat.ps1 - Re-applies the LDPlayer debloat. Safe to run any number of times.
# Works for any LDPlayer version installed at the usual locations. Self-elevates to admin.
# Everything it moves goes into C:\LDPlayer\vault. Nothing is deleted.
# If auto-detection fails, set $LD_ROOT by hand (the folder that contains ldconsole.exe).
$LD_ROOT = $null
foreach ($candidate in @('C:\LDPlayer\LDPlayer9','C:\LDPlayer\LDPlayer12','C:\LDPlayer\LDPlayer5','C:\LDPlayer\LDPlayer4','C:\LDPlayer\LDPlayer9x')) {
  if (Test-Path "$candidate\ldconsole.exe") { $LD_ROOT = $candidate; break }
}
if (-not $LD_ROOT) {
  $hit = Get-ChildItem 'C:\LDPlayer' -Directory -Force -ErrorAction SilentlyContinue | Where-Object { Test-Path (Join-Path $_.FullName 'ldconsole.exe') } | Select-Object -First 1
  if ($hit) { $LD_ROOT = $hit.FullName }
}
if (-not $LD_ROOT) { Write-Host 'ERROR: no LDPlayer install with ldconsole.exe found under C:\LDPlayer. Set $LD_ROOT manually.'; exit 2 }

$Log = 'C:\LDPlayer\reapply-log.txt'
function Log($m){
  $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $m"
  Add-Content -Path $Log -Value $line -Encoding ASCII
  Write-Host $line
}
Log "using install root: $LD_ROOT"
$LD_PACKAGE = "$LD_ROOT\..\ldmutiplayer"
if (-not (Test-Path $LD_PACKAGE)) { $LD_PACKAGE = $null }

# --- self-elevate if needed ---
$id = [Security.Principal.WindowsIdentity]::GetCurrent()
$p  = New-Object Security.Principal.WindowsPrincipal($id)
if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Log 'not elevated; relaunching as administrator...'
  Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
  exit
}

Log '=== reapply-debloat start ==='

# --- 1) vault restored bloat ---
$vault = Join-Path 'C:\LDPlayer\vault' ("after-" + (Get-Date -Format 'yyyyMMdd-HHmmss'))
$candidates = @(
  "$LD_ROOT\ldplayerpartner.exe",
  "$LD_ROOT\ldplayerpartner2.exe",
  "$LD_ROOT\bugreport.exe",
  "$LD_ROOT\dnrepairer.exe",
  "$LD_ROOT\LDPlayer_*.exe",
  "$LD_ROOT\log\ldpartner.log"
)
if ($LD_PACKAGE) { $candidates += "$LD_PACKAGE\bugreport.exe" }
foreach ($item in $candidates) {
  $parent = Split-Path $item -Parent
  $leaf   = Split-Path $item -Leaf
  if (Test-Path $parent) {
    Get-ChildItem $parent -Filter $leaf -Force -ErrorAction SilentlyContinue | ForEach-Object {
      $dest = Join-Path $vault (Split-Path $_.DirectoryName -Leaf)
      New-Item -ItemType Directory -Force -Path $dest | Out-Null
      Move-Item $_.FullName (Join-Path $dest $_.Name) -Force
      Log "vaulted: $($_.FullName)"
    }
  }
}

# --- 1b) crash-telemetry SDK re-vaulted ---
$upload = Join-Path $LD_ROOT 'upload'
if (Test-Path $upload) { Move-Item $upload (Join-Path $vault 'upload') -Force; Log 'vaulted: telemetry SDK (upload\)' }

# --- 1c) app-store intercept/ad staging feed re-vaulted ---
$appStore = $null
foreach ($cand in @("$env:USERPROFILE\Documents\XuanZhi9\Applications","$env:USERPROFILE\Documents\XuanZhi\Applications","$env:USERPROFILE\Documents\Letu\Applications")) {
  if ($cand -and (Test-Path $cand)) { $appStore = $cand; break }
}
if ($appStore) {
  foreach ($item in @('ld_launcher','cpi.data','appInfo.txt')) {
    $src = Join-Path $appStore $item
    if (Test-Path $src) {
      $dest = Join-Path $vault 'intercept'; New-Item -ItemType Directory -Force -Path $dest | Out-Null
      Move-Item $src (Join-Path $dest (Split-Path $src -Leaf)) -Force
      Log "vaulted: $src"
    }
  }
  Get-ChildItem $appStore -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^[0-9a-f]{32}$' } | Move-Item -Destination (Join-Path $vault 'intercept') -Force
}

# --- 1d) recommendation/ad DB re-vaulted ---
$rec = "$LD_ROOT\vms\recommendConfigs"
if (Test-Path $rec) {
  foreach ($item in @('dir_kmps.dir','dir_jmps.dir','dir_noices.dir','dir_commons.dir','package_configs_1005','package_configs_1005.rcc')) {
    $src = Join-Path $rec $item
    if (Test-Path $src) {
      $dest = Join-Path $vault 'recommendConfigs'; New-Item -ItemType Directory -Force -Path $dest | Out-Null
      Move-Item $src (Join-Path $dest $item) -Force
      Log "vaulted: $src"
    }
  }
}

# --- 2) purge + re-seal ad cache ---
$cache = $null
foreach ($cand in @("$env:APPDATA\XuanZhi9\cache","$env:APPDATA\XuanZhi\cache","$env:APPDATA\Letu\cache")) {
  if (Test-Path $cand) { $cache = $cand; break }
}
if ($cache) {
  $pending = Get-ChildItem $cache -Force -ErrorAction SilentlyContinue
  if ($pending) {
    $cd = Join-Path $vault 'adcache'; New-Item -ItemType Directory -Force -Path $cd | Out-Null
    $pending | Move-Item -Destination $cd -Force
    Log 'ad cache contents vaulted'
  }
  icacls $cache /remove:d Everyone 2>&1 | Out-Null
  icacls $cache /deny 'Everyone:(OI)(CI)W' 2>&1 | Out-Null
  Log 'ad cache sealed'
} else { Log 'no ad cache folder found - skipping seal' }

# --- 3) re-pin update/telemetry pins (handles missing keys gracefully) ---
$cfgPath = "$LD_ROOT\vms\config\leidians.config"
if (Test-Path $cfgPath) {
  try {
    $cfg = Get-Content $cfgPath -Raw | ConvertFrom-Json
    foreach ($k in @('reportPCInfoTime','adLoadtime','nextCheckupdateTime')) {
      if ($cfg.PSObject.Properties.Name -contains $k) {
        if ($k -eq 'reportPCInfoTime') { $cfg.$k = '20990101' } else { $cfg.$k = 4102444800 }
      }
    }
    if ($cfg.PSObject.Properties.Name -contains 'noiceUserRed') { $cfg.noiceUserRed = $false }
    [System.IO.File]::WriteAllText($cfgPath, ($cfg | ConvertTo-Json -Depth 5), (New-Object System.Text.ASCIIEncoding))
    Log 'leidians.config pins re-applied (present keys only)'
  } catch { Log "leidians.config patch failed: $($_.Exception.Message)" }
} else { Log 'leidians.config not found - skipping config pins' }

# --- 4) CPU back to 3 via official CLI ---
$ldconsole = "$LD_ROOT\ldconsole.exe"
if (Test-Path $ldconsole) {
  & $ldconsole modify --index 0 --cpu 3 2>&1 | Out-String | ForEach-Object { Log "ldconsole: $_" }
}

# --- 5) telemetry/ad service disabled ---
foreach ($svcName in @('LDPlayerENSvr','LDPlayerENSvc','LDPlayerServiceEN')) {
  try {
    $svc = Get-Service $svcName -ErrorAction Stop
    if ($svc.Status -ne 'Stopped') { Stop-Service $svcName -Force }
    Set-Service $svcName -StartupType Disabled
    Log "$svcName stopped + disabled"
  } catch { Log "$svcName not found (ok)" }
}

# --- 6) hosts block: ensure present ---
$hostsPath = 'C:\Windows\System32\drivers\etc\hosts'
$hostsRaw  = Get-Content $hostsPath -Raw
if ($hostsRaw -notmatch 'LDPlayer-Debloat-Block-Begin') {
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
  [System.IO.File]::AppendAllText($hostsPath, $block, (New-Object System.Text.ASCIIEncoding))
  Log 'hosts block applied'
} else { Log 'hosts block already present' }

# --- 7) firewall rules (only for files that actually exist) ---
$rules = @{
  'LDPlayerBlock-ldplayerpartner'   = "$LD_ROOT\ldplayerpartner.exe"
  'LDPlayerBlock-ldplayerpartner2'  = "$LD_ROOT\ldplayerpartner2.exe"
  'LDPlayerBlock-dnrepairer'        = "$LD_ROOT\dnrepairer.exe"
  'LDPlayerBlock-bugreport'         = "$LD_ROOT\bugreport.exe"
  'LDPlayerBlock-ldplayerserviceEN' = "$LD_ROOT\ldplayerserviceEN.exe"
  'LDPlayerBlock-ldupload'          = "$LD_ROOT\upload\ldupload.exe"
}
if ($LD_PACKAGE) { $rules['LDPlayerBlock-bugreport-manager'] = "$LD_PACKAGE\bugreport.exe" }
foreach ($name in $rules.Keys) {
  $prog = $rules[$name]
  if (Test-Path $prog) {
    if (-not (Get-NetFirewallRule -DisplayName $name -ErrorAction SilentlyContinue)) {
      New-NetFirewallRule -DisplayName $name -Direction Outbound -Action Block -Program $prog -Profile Any -Enabled True | Out-Null
      Log "firewall rule created: $name"
    }
  }
}

# --- 8) in-Android state (only if the emulator is running right now) ---
$adb = "$LD_ROOT\adb.exe"
if (Test-Path $adb) {
  $out = (& $adb devices | Out-String)
  if ($out -match 'emulator-\d+\s+device') {
    Log 'adb: device attached - re-applying in-Android debloat'
    & 'C:\LDPlayer\android-refresh.ps1' | ForEach-Object { Log "  android: $_" }
  } else { Log 'adb: emulator not attached (Android state persists in its data image)' }
}

Log '=== reapply-debloat done ==='
