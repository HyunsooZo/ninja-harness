#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$env:PYTHONUTF8 = "1"
$env:PYTHONIOENCODING = "utf-8"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding

$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $Root

function Fail([string]$Message) {
  Write-Error "[FAIL] $Message"
  exit 1
}

$Python = Get-Command python3 -ErrorAction SilentlyContinue
if (-not $Python) {
  $Python = Get-Command python -ErrorAction SilentlyContinue
}

if (-not $Python) {
  Fail "python3 or python is required for harness structure verification."
}

& $Python.Source "scripts/verify-harness-structure.py"
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}
