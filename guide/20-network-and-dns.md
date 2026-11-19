# 20 — Network & DNS

## Objective

Keep the ad-blocking DNS and hosts fence effective without breaking app downloads, logins, or multiplayer connectivity.

## Verify the current state

```powershell
$adb = 'C:\LDPlayer\LDPlayer9\adb.exe'
& $adb shell settings get global private_dns_mode        # hostname
& $adb shell settings get global private_dns_specifier   # dns.adguard.com
Get-Content 'C:\Windows\System32\drivers\etc\hosts' -Raw |
  Select-String 'LDPlayer-Debloat-Block-'
Get-NetFirewallRule -DisplayName 'LDPlayerBlock-*' |
  Select-Object DisplayName, Enabled
```

## Guest DNS options

| Mode | Effect |
|---|---|
| `hostname` + `dns.adguard.com` | Blocks ads/telemetry at DNS level (default in this playbook) |
| `opportunistic` | Plain DNS — use only if a title cannot resolve through Private DNS |
| `off` | System DNS — diagnostic only |

```powershell
# switch temporarily, then restore
& $adb shell settings put global private_dns_mode opportunistic
& $adb shell settings put global private_dns_specifier dns.adguard.com
```

## Connectivity checks

```powershell
$adb = 'C:\LDPlayer\LDPlayer9\adb.exe'
& $adb shell ping -c 3 1.1.1.1
& $adb shell ping -c 3 dns.google
& $adb shell settings get global http_proxy     # should be :0 or empty
```

## Host-side fence interaction

The hosts block covers LDPlayer's own ad/telemetry domains only. It does not touch game/CDN domains. If an update must fetch a payload:

```powershell
# temporarily comment out the marked fence, update, then:
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\reapply-debloat.ps1
```

## Failure modes

| Symptom | Fix |
|---|---|
| App cannot reach its server | Switch DNS mode to `opportunistic` temporarily; re-test |
| Downloads fail only in guest | Check `http_proxy` is unset; verify hosts fence doesn't include that CDN |
| Ads return after update | Reapply script re-sets DNS when the emulator is attached ([12](12-android.md)) |
| High latency in multiplayer | Test host network first; emulator NAT adds a small hop — avoid VPN chains |

**Next:** [21 — Per-title profiles](21-per-title-profiles.md)
