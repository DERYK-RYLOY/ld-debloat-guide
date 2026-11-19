# 21 — Per-title profiles

## Objective

Store a reproducible configuration for every app/game so switching titles does not mean rediscovering settings.

## Capture a title's facts

```powershell
$adb = 'C:\LDPlayer\LDPlayer9\adb.exe'
$aapt = 'C:\LDPlayer\LDPlayer9\aapt.exe'
& $aapt dump badging 'C:\path\to\title.apk' |
  Select-String 'package:|sdkVersion:|targetSdkVersion:|native-code:'
& $adb shell pm list packages -3
& $adb shell dumpsys package <package> | Select-String 'versionName|targetSdk'
```

Store per title under `profiles/<title>.md` using this template:

```markdown
# <Title>

- Package: `com.example.title`
- Version: 1.2.3  ·  minSdk 21  ·  targetSdk 30
- Native libs: arm64-v8a (translation ON)

| Setting | Value |
|---|---|
| Instance | index 0, dedicated instance |
| Android profile | 9 (64-bit) |
| CPU / RAM | 4 vCPU / 3072 MB |
| Renderer | DirectX / OpenGL / Vulkan |
| Resolution / DPI | 1920x1080 / 320 |
| Frame cap | 60 |
| DNS mode | hostname (adguard) |
| Identity profile | <name> (see 18) |
| Keymap | <scheme name> |
| ARM translation | ON / OFF |
| Notes | launch flags, known quirks |

## Recipe
1. ...
2. ...

## Verification
- [ ] cold boot < X s
- [ ] stable frame rate
- [ ] no "unsupported device" screen
```

## Apply a profile

```powershell
# 1. switch instance if the title needs its own
& 'C:\LDPlayer\LDPlayer9\ldconsole.exe' launch --index 1

# 2. set CPU/RAM for that instance
& 'C:\LDPlayer\LDPlayer9\ldconsole.exe' modify --index 1 --cpu 4

# 3. apply guest-side state after boot
powershell -NoProfile -ExecutionPolicy Bypass -File C:\LDPlayer\android-refresh.ps1

# 4. verify
& 'C:\LDPlayer\LDPlayer9\ldconsole.exe' list2
```

## Rules

- One instance per demanding title; shared instances cross-contaminate keymaps and identity.
- Never copy `data.vmdk` between running instances — stop first.
- Record the baseline and post-tuning numbers from [14](14-performance-baseline.md).

**Next:** [22 — Benchmark & verify](22-benchmark-and-verify.md)
