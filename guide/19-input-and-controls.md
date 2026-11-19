# 19 — Input & controls

## Objective

Reliable control schemes for keyboard, mouse, gamepad and touch, including per-title keymaps.

## ADB input tests (read-only device state, mutating input only)

```powershell
$adb = 'C:\LDPlayer\LDPlayer9\adb.exe'
& $adb shell input tap 960 540
& $adb shell input swipe 960 700 960 300 250
& $adb shell input text 'test'
& $adb shell dumpsys input | Select-String 'SurfaceOrientation|Display' | Select-Object -First 10
```

## Keymap workflow (LDPlayer UI)

1. Open the title in the emulator.
2. Open the keymapping panel (default: `Ctrl+K` or the floating keyboard icon).
3. Place tap-zones on fixed UI elements; use **skill buttons** for directional/aimed abilities.
4. Save the scheme; it is stored per package, so it survives launching other titles.
5. Verify by replaying one full session without touching the mouse.

## Gamepad

```powershell
& 'C:\LDPlayer\LDPlayer9\adb.exe' shell dumpsys input_device | Select-String -Pattern 'Gamepad|KEYBOARD|TOUCHSCREEN'
```

Enable gamepad mapping in LDPlayer settings when the physical controller is detected. Map analog sticks to movement and shoulder buttons to skills; keep touch fallback for menus.

## Multi-touch

Check that the title supports the guest's touch source count:

```powershell
& 'C:\LDPlayer\LDPlayer9\adb.exe' shell dumpsys input | Select-String 'Touch' | Select-Object -First 8
```

Some titles disable multi-touch when they detect a mouse input source — use the keymap's touch mode for those.

## Failure modes

| Symptom | Fix |
|---|---|
| Taps land offset | Wrong resolution/DPI profile — align with [15](15-renderer-and-gpu.md) |
| Held keys register as single taps | Use skill-button mode instead of tap-zone |
| Gamepad works in menus only | Title requires touch for skills — map those explicitly |
| Keymap lost after update | Re-import the per-title profile ([21](21-per-title-profiles.md)) |

**Next:** [20 — Network & DNS](20-network-and-dns.md)
