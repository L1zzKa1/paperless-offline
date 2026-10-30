$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
if (-not (Test-Path '.env')) {
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    function New-Hex([int]$n) {
        $buf = New-Object byte[] $n
        $rng.GetBytes($buf)
        return ([BitConverter]::ToString($buf)).Replace('-', '').ToLowerInvariant()
    }
    @("DB_PASSWORD=$(New-Hex 32)", "PAPERLESS_SECRET_KEY=$(New-Hex 48)") | Set-Content -Path '.env' -Encoding Ascii
    Write-Host 'Generated secure .env. Back up this file safely.'
}
$parts = @(Get-ChildItem -File 'images.part-*' | Sort-Object Name)
if ($parts.Count -eq 0) { throw 'No images.part-* found in folder' }
$shaLine = Get-Content SHA256SUMS.txt
foreach ($part in $parts) {
    $expectedLine = $shaLine | Where-Object { $_ -match [regex]::Escape($part.Name) + '$' } | Select-Object -First 1
    if (-not $expectedLine) { throw "Missing hash for $($part.Name)" }
    $expected = ($expectedLine -split '\s+')[0]
    $actual = (Get-FileHash $part.FullName -Algorithm SHA256).Hash
    if ($actual -ine $expected) { throw "Hash mismatch: $($part.Name)" }
}
Write-Host 'Checksums OK. Combining archive...'
$out = [System.IO.File]::Create((Join-Path $PSScriptRoot 'images.tar.gz'))
try {
    foreach ($part in $parts) {
        $inFile = [System.IO.File]::OpenRead($part.FullName)
        try { $inFile.CopyTo($out) } finally { $inFile.Dispose() }
    }
} finally { $out.Dispose() }
Write-Host 'Importing images...'
cmd /c 'docker load -i images.tar.gz'
if ($LASTEXITCODE -ne 0) { throw 'docker load failed' }
Write-Host 'Starting services without pulling...'
docker compose config --quiet
if ($LASTEXITCODE -ne 0) { throw 'Invalid Compose config' }
docker compose up -d --pull never
if ($LASTEXITCODE -ne 0) { throw 'Compose start failed' }
docker compose ps
Write-Host 'Open http://localhost:8000 after services initialize.'
