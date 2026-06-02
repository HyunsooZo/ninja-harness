#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $Root

function Fail([string]$Message) {
  Write-Error "[FAIL] $Message"
  exit 1
}

function Find-CommandName([string[]]$Names) {
  foreach ($Name in $Names) {
    $Command = Get-Command $Name -ErrorAction SilentlyContinue
    if ($Command) {
      return $Command.Source
    }
  }
  return $null
}

$RequiredFiles = @(
  "AGENTS.md",
  "CLAUDE.md",
  "Makefile",
  "scripts/verify-harness-structure.sh",
  "scripts/verify-harness-structure.ps1",
  "scripts/verify-harness-structure.py",
  "scripts/verify-project-gates.sh",
  "scripts/verify-project-gates.ps1",
  "scripts/verify-project-gates.py",
  "scripts/sync-skills.sh",
  "scripts/sync-skills.py",
  "scripts/sync-skills.ps1",
  "scripts/check-profile-readiness.sh",
  "scripts/self-test-harness-gates.sh",
  "scripts/collect-eval-metrics.sh",
  "scripts/check-completed-plan-quality.sh",
  "scripts/check-completed-plan-quality.ps1",
  "scripts/check-completed-plan-quality.py",
  "scripts/set-codex-agent-model.sh"
)

foreach ($Path in $RequiredFiles) {
  if (-not (Test-Path $Path)) {
    Fail "missing required file: $Path"
  }
}

$Python = Find-CommandName @("python3", "python")
if (-not $Python) {
  Fail "python3 or python is required"
}

$Git = Find-CommandName @("git")
if (-not $Git) {
  Fail "git is required"
}

$Bash = Find-CommandName @("bash")
$Make = Find-CommandName @("make")
$MissingPosixTools = @()

& $Python -c "import importlib.util, sys; parser = 'tomllib' if importlib.util.find_spec('tomllib') else ('tomli' if importlib.util.find_spec('tomli') else ''); print('[OK] Python TOML parser ready: ' + parser if parser else '[FAIL] Python TOML parser is required: use Python 3.11+ or install tomli'); sys.exit(0 if parser else 1)"
if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}

Write-Host "[OK] PowerShell version: $($PSVersionTable.PSVersion)"
Write-Host "[OK] python: $Python"
Write-Host "[OK] git: $Git"

if ($Bash) {
  Write-Host "[OK] bash: $Bash"
  & $Bash -n scripts/*.sh
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }
} else {
  $MissingPosixTools += "bash"
  Write-Host "[WARN] bash not found; Makefile and shell-script targets require Git Bash, MSYS, WSL, or another POSIX-compatible shell"
}

if ($Make) {
  Write-Host "[OK] make: $Make"
} else {
  $MissingPosixTools += "make"
  Write-Host "[WARN] make not found; use PowerShell wrapper scripts or install make for Makefile targets"
}

Write-Host "[OK] harness PowerShell structure and project gate tooling looks ready"

if ($MissingPosixTools.Count -gt 0) {
  Write-Host "[WARN] full Makefile/Bash tooling is incomplete: $($MissingPosixTools -join ', ')"
} else {
  Write-Host "[OK] full Makefile/Bash tooling looks ready"
}
