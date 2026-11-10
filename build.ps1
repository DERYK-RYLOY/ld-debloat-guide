# Build the final LD-Debloat-Guide.html (S1..S4 + steps + rest + injected appendix)
# Then print to the repo's LD-Debloat-Guide.pdf
$ErrorActionPreference = 'Stop'
$src     = 'C:\Users\Admin\Downloads\ld-debloat-guide'
$build   = Join-Path $src 'src\guide-build.html'
$s5      = Join-Path $src 'src\frag-s5.html'
$rest    = Join-Path $src 'src\frag-rest.html'
$outHtml = Join-Path $src 'src\LD-Debloat-Guide.html'
$pdf     = Join-Path $src 'LD-Debloat-Guide.pdf'

function EscHtml([string]$s) {
  return $s.Replace('&','&amp;').Replace('<','&lt;').Replace('>','&gt;')
}

$head = [System.IO.File]::ReadAllText($build, [System.Text.Encoding]::UTF8)
$steps = [System.IO.File]::ReadAllText($s5,   [System.Text.Encoding]::UTF8)
$tail  = [System.IO.File]::ReadAllText($rest, [System.Text.Encoding]::UTF8)

$scriptList = @(
  @{ name='reapply-debloat.ps1'; why='Master re-fixer. Idempotent. Self-elevating.' },
  @{ name='clean-launch.ps1';    why='Launch LDPlayer and re-sweep 75 seconds later (catches the launch-time re-download).' },
  @{ name='android-refresh.ps1'; why='Inside-Android re-apply (LD packages disabled, Private DNS, Lawnchair HOME).' },
  @{ name='verify-debloat.ps1';  why='Read-only audit. Exit code = number of FAILs.' },
  @{ name='verify-android.ps1';  why='Read-only audit (Android side). Exit code = number of FAILs.' }
)
$sb = New-Object System.Text.StringBuilder
foreach ($s in $scriptList) {
  $path = Join-Path (Join-Path $src 'scripts') $s.name
  if (-not (Test-Path $path)) { Write-Host "MISSING: $path"; exit 1 }
  $body = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
  [void]$sb.Append('<h3 class="sub" style="margin-top:16px">')
  [void]$sb.Append($s.name)
  [void]$sb.Append('</h3><p class="muted">')
  [void]$sb.Append((EscHtml $s.why))
  [void]$sb.Append('</p><pre class="cmd">')
  [void]$sb.Append((EscHtml $body))
  [void]$sb.Append('</pre>')
}

$body = $head + $steps + $tail
$body = $body.Replace('<!-- APPENDIX_G_INJECT -->', $sb.ToString())
[System.IO.File]::WriteAllText($outHtml, $body, (New-Object System.Text.UTF8Encoding($false)))
Write-Host ('built: {0} bytes' -f (Get-Item $outHtml).Length)

$ErrorActionPreference = 'Continue'
$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
& $edge --headless=new --disable-gpu --no-pdf-header-footer --user-data-dir='C:\Users\Admin\AppData\Local\Temp\edge-build' --print-to-pdf="$pdf" "file:///C:/Users/Admin/Downloads/ld-debloat-guide/src/LD-Debloat-Guide.html" 2>&1 | Out-Null
Write-Host ('pdf: {0} KB' -f [math]::Round((Get-Item $pdf).Length/1KB,1))
