#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$env:PYTHONUTF8 = "1"
$env:PYTHONIOENCODING = "utf-8"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding

$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $Root

$Python = Get-Command python3 -ErrorAction SilentlyContinue
if (-not $Python) {
  $Python = Get-Command python -ErrorAction SilentlyContinue
}

if (-not $Python) {
  Write-Error "[FAIL] python3 or python is required for evidence gate hook."
  exit 1
}

$InputPayload = [Console]::In.ReadToEnd()
$InputPayload | & $Python.Source "scripts/check-evidence-gate-hook.py"
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}
