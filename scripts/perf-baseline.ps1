# perf-baseline.ps1 — read-only performance snapshot
# Auto-detects the LDPlayer install. Writes nothing; redirect output to a file for A/B comparisons.
$LD = $null
foreach ($c in @('C:\LDPlayer\LDPlayer9','C:\LDPlayer\LDPlayer12','C:\LDPlayer\LDPlayer5','C:\LDPlayer\LDPlayer4')) {
  if (Test-Path "$c\ldconsole.exe") { $LD = $c; break }
}
if (-not $LD) {
  $hit = Get-ChildItem 'C:\LDPlayer' -Directory -Force -ErrorAction SilentlyContinue |
    Where-Object { Test-Path (Join-Path $_.FullName 'ldconsole.exe') } | Select-Object -First 1
  if ($hit) { $LD = $hit.FullName }
}
if (-not $LD) { Write-Host 'ERROR: LDPlayer install not found'; exit 2 }

Write-Host "=== LDPlayer ==="
Write-Host ("install : $LD")
$ver = (Get-Item "$LD\dnplayer.exe" -ErrorAction SilentlyContinue).VersionInfo.ProductVersion
Write-Host ("version : $ver")
Write-Host '--- instances ---'
& "$LD\ldconsole.exe" list2 2>&1

Write-Host '--- guest VM definition ---'
$vbox = Join-Path $LD 'vms\leidian0\leidian.vbox'
if (Test-Path $vbox) {
  Get-Content $vbox | Select-String 'CPU count|RAMSize|MACAddress|OSType' | ForEach-Object { $_.Line.Trim() }
}

Write-Host '--- telemetry pins ---'
$cfg = Join-Path $LD 'vms\config\leidians.config'
if (Test-Path $cfg) {
  $j = Get-Content $cfg -Raw | ConvertFrom-Json
  foreach ($k in 'reportPCInfoTime','adLoadtime','nextCheckupdateTime') {
    if ($j.PSObject.Properties.Name -contains $k) { '{0,-22} {1}' -f $k, $j.$k }
  }
}

Write-Host '--- services ---'
foreach ($s in 'LDPlayerENSvr','LDPlayerENSvc','LDPlayerServiceEN') {
  $svc = Get-Service $s -ErrorAction SilentlyContinue
  if ($svc) { '{0,-22} {1} / {2}' -f $s, $svc.Status, $svc.StartType }
}

Write-Host '--- host ---'
Get-CimInstance Win32_Processor | ForEach-Object { 'cpu     : ' + $_.Name }
Get-CimInstance Win32_VideoController | ForEach-Object { 'gpu     : ' + $_.Name + '  driver ' + $_.DriverVersion }
$os = Get-CimInstance Win32_OperatingSystem
Write-Host ("ram     : {0:N1} GB total, {1:N1} GB free" -f ($os.TotalVisibleMemorySize/1MB), ($os.FreePhysicalMemory/1MB))
Get-Volume C | ForEach-Object { 'volume C: {0}, {1:N1} GB free' -f $_.FileSystem, ($_.SizeRemaining/1GB) }

Write-Host '--- last VM boot lines ---'
$log = Join-Path $LD 'vms\leidian0\Logs\VBox.log'
if (Test-Path $log) { Get-Content $log -Tail 8 } else { Write-Host '(no VBox.log yet)' }
