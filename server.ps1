$ErrorActionPreference = 'Stop'
$root = Join-Path $PSScriptRoot 'site'
$mime = @{ '.html'='text/html; charset=utf-8'; '.js'='application/javascript; charset=utf-8'; '.json'='application/json; charset=utf-8'; '.jpg'='image/jpeg'; '.png'='image/png'; '.svg'='image/svg+xml'; '.css'='text/css' }
$listener = $null
foreach ($port in 8642, 8643, 8644, 8650, 8765) {
  try { $l = New-Object System.Net.HttpListener; $l.Prefixes.Add("http://localhost:$port/"); $l.Start(); $listener = $l; break } catch { }
}
if (-not $listener) { Write-Host 'Не удалось открыть локальный порт. Закройте другие программы-серверы и попробуйте снова.'; Read-Host 'Enter'; exit 1 }
Write-Host "Проект открыт в браузере: http://localhost:$port/"
Write-Host 'Не закрывайте это окно, пока смотрите проект. Чтобы остановить, закройте окно.'
Start-Process "http://localhost:$port/index.html"
while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  try {
    $rel = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart('/'))
    if ($rel -eq '') { $rel = 'index.html' }
    $file = [IO.Path]::GetFullPath((Join-Path $root $rel))
    if ($file.StartsWith($root) -and (Test-Path -LiteralPath $file -PathType Leaf)) {
      $bytes = [IO.File]::ReadAllBytes($file)
      $ext = [IO.Path]::GetExtension($file).ToLower()
      if ($mime.ContainsKey($ext)) { $ctx.Response.ContentType = $mime[$ext] } else { $ctx.Response.ContentType = 'application/octet-stream' }
      $ctx.Response.ContentLength64 = $bytes.Length
      $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else { $ctx.Response.StatusCode = 404 }
  } catch { } finally { $ctx.Response.Close() }
}
