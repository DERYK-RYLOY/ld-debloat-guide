# clean-launch.ps1 - LD purge, launch, then watcher sweep ~75s later. Run it instead of the stock shortcut.
# Self-elevates. Finds your LDPlayer folder automatically. -WatchOnly is internal; do not run it directly.
param([switch]$WatchOnly)
$LD_ROOT = $null
foreach ($candidate in @('C:\LDPlayer\LDPlayer9','C:\LDPlayer\LDPlayer12','C:\LDPlayer\LDPlayer5','C:\LDPlayer\LDPlayer4','C:\LDPlayer\LDPlayer9x')) {
  if (Test-Path "$candidate\ldconsole.exe") { $LD_ROOT = $candidate; break }
}
if (-not $LD_ROOT) {
  $hit = Get-ChildItem 'C:\LDPlayer' -Directory -Force -ErrorAction SilentlyContinue | Where-Object { Test-Path (Join-Path $_.FullName 'ldconsole.exe') } | Select-Object -First 1
  if ($hit) { $LD_ROOT = $hit.FullName }
}
$reapply = 'C:\LDPlayer\reapply-debloat.ps1'
$log = 'C:\LDPlayer\reapply-log.txt'
function Log($m){ Add-Content $log "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss')  $m"; Write-Host $m }

if (-not $LD_ROOT) { Write-Host 'ERROR: LDPlayer install not found. Set LD_ROOT in clean-launch.ps1.'; exit 2 }

# --- self-elevate ---
$id = [Security.Principal.WindowsIdentity]::GetCurrent()
$p  = New-Object Security.Principal.WindowsPrincipal($id)
if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  $a = if ($WatchOnly) { '-WatchOnly' } else { '' }
  Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`" $a"
  exit
}

if ($WatchOnly) {
  Log 'post-launch watcher: waiting 75s...'
  Start-Sleep -Seconds 75
  & $reapply | ForEach-Object { }
  Log 'post-launch sweep done'
  exit 0
}

Log "=== clean-launch via $LD_ROOT ==="
& $reapply | Out-Null
Log "launching LDPlayer (index 0)..."
& "$LD_ROOT\ldconsole.exe" launch --index 0
Log 'spawning detached watcher'
Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`" -WatchOnly" -WindowStyle Hidden
Log '=== clean-launch done ==='
