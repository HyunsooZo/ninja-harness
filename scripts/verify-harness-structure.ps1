#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $Root

function Fail([string]$Message) {
  Write-Error "[FAIL] $Message"
  exit 1
}

$Bash = Get-Command bash -ErrorAction SilentlyContinue
if (-not $Bash) {
  Fail "bash is required for the current structure verifier. On Windows, install Git for Windows, MSYS2, or run the harness in WSL."
}

& $Bash.Source "scripts/verify-harness-structure.sh"
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}
