#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$env:PYTHONUTF8 = "1"
$env:PYTHONIOENCODING = "utf-8"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding

$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$Python = Get-Command python3 -ErrorAction SilentlyContinue
if (-not $Python) {
  $Python = Get-Command python -ErrorAction SilentlyContinue
}

if (-not $Python) {
  Write-Error "[FAIL] python3 or python is required for harness upgrade checks."
  exit 1
}

& $Python.Source (Join-Path $Root "scripts/check-harness-upgrade.py") --root $Root @args
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}
