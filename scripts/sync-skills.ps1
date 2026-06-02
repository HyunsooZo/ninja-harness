Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$env:PYTHONUTF8 = "1"
$env:PYTHONIOENCODING = "utf-8"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding

$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $Root

$Python = Get-Command python3 -ErrorAction SilentlyContinue
if ($null -eq $Python) {
  $Python = Get-Command python -ErrorAction SilentlyContinue
}
if ($null -eq $Python) {
  Write-Error "[FAIL] python3 or python is required"
  exit 1
}

& $Python.Source "scripts/sync-skills.py"
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}
