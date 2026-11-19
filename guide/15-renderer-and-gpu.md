# 15 — Renderer & GPU

## Objective

Use the host GPU efficiently: correct renderer backend, sane resolution/DPI, stable frame pacing, no software fallback.

## Identify the active graphics stack

```powershell
$LD = 'C:\LDPlayer\LDPlayer9'
Get-ChildItem "$LD\gpu" -File | Select-Object Name, Length
Get-Content "$LD\vms\leidian0\Logs\VBox.log" |
  Select-String 'EGL|OpenGL|GLInfo|fastpipe|Vulkan|GRAPHICS|VRAM' | Select-Object -Last 30
```

`fastpipe` present in the log means the guest display bridge is active. Software rendering shows up as slow boots and high host CPU with low GPU usage.

## Host GPU sanity

```powershell
Get-CimInstance Win32_VideoController |
  Select-Object Name, DriverVersion, AdapterRAM, CurrentHorizontalResolution
dxdiag /t "$env:TEMP\dxdiag.txt"    # then read GPU section
```

Keep the host GPU driver current; LDPlayer's OpenGL/Vulkan translators depend on it.

## Renderer selection (LDPlayer UI)

Settings → Display:

| Setting | Guidance |
|---|---|
| Renderer | Prefer DirectX/OpenGL hardware mode; try Vulkan for titles that support it. Software mode only for diagnosis |
| Resolution | Match the host desktop or one step below; 1920×1080 is a safe reference |
| DPI | 320–480; higher DPI costs fill rate without improving most games |
| Frame rate | 60 FPS cap for stability; raise to 90/120 only if the host sustains it |
| VSync | On when tearing/stutter appears; off when measuring raw throughput |

## Verify a renderer change

```powershell
& 'C:\LDPlayer\LDPlayer9\adb.exe' shell wm size
& 'C:\LDPlayer\LDPlayer9\adb.exe' shell wm density
& 'C:\LDPlayer\LDPlayer9\ldconsole.exe' reboot --index 0
Start-Sleep -Seconds 30
Get-Content 'C:\LDPlayer\LDPlayer9\vms\leidian0\Logs\VBox.log' -Tail 20
```

Then re-run the same title and compare against the [baseline](14-performance-baseline.md).

## Failure modes

| Symptom | Fix |
|---|---|
| Black screen / flicker after renderer change | Switch back to the previous renderer; update host GPU driver |
| High host CPU, low GPU | Software fallback selected — re-select hardware renderer |
| Stutter at high FPS | Cap to 60; lower resolution before lowering quality in-game |
| Artifacts only in one title | Per-title renderer profile ([21](21-per-title-profiles.md)) |

**Next:** [16 — Storage & I/O](16-storage-io.md)
