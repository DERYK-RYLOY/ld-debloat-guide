# profile-check.ps1 — read-only guest identity / state audit over ADB
$LD = $null
foreach ($c in @('C:\LDPlayer\LDPlayer9','C:\LDPlayer\LDPlayer12','C:\LDPlayer\LDPlayer5','C:\LDPlayer\LDPlayer4')) {
  if (Test-Path "$c\adb.exe") { $LD = $c; break }
}
if (-not $LD) {
  $hit = Get-ChildItem 'C:\LDPlayer' -Directory -Force -ErrorAction SilentlyContinue |
    Where-Object { Test-Path (Join-Path $_.FullName 'adb.exe') } | Select-Object -First 1
  if ($hit) { $LD = $hit.FullName }
}
if (-not $LD) { Write-Host 'ERROR: LDPlayer install not found'; exit 2 }
$adb = Join-Path $LD 'adb.exe'
$dev = (& $adb devices | Out-String)
if ($dev -notmatch 'emulator-\d+\s+device') {
  Write-Host 'SKIP: no emulator attached (enable ADB debugging and start the emulator)'
  exit 0
}
Write-Host "ADB: connected ($LD)"
Write-Host '--- identity ---'
foreach ($p in 'ro.product.model','ro.product.brand','ro.product.manufacturer',
               'ro.build.fingerprint','ro.build.version.release','ro.build.version.sdk',
               'ro.product.cpu.abilist','ro.sf.lcd_density','gsm.operator.alpha') {
  $v = (& $adb shell getprop $p | Out-String).Trim()
  '{0,-32} {1}' -f $p, $v
}
Write-Host '--- network ---'
foreach ($p in 'private_dns_mode','private_dns_specifier','http_proxy') {
  '{0,-32} {1}' -f $p, ((& $adb shell settings get global $p | Out-String).Trim())
}
Write-Host '--- HOME ---'
$homeActivity = (& $adb shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME | Out-String).Trim()
Write-Host $homeActivity
Write-Host '--- packages ---'
$thirdParty = (& $adb shell pm list packages -3 | Out-String) -replace 'package:','' -split "`r?`n" | Where-Object { $_.Trim() }
Write-Host ('third-party: ' + (($thirdParty | Where-Object { $_.Trim() }) -join ', '))
$disabled = (& $adb shell pm list packages -d | Out-String) -replace 'package:','' -split "`r?`n" | Where-Object { $_.Trim() }
Write-Host ('disabled  : ' + (($disabled | Where-Object { $_.Trim() }) -join ', '))
Write-Host '--- done ---'
