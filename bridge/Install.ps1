# This script copies the bridge to C: and registers a user-scoped startup task.
# Run ONCE in Windows PowerShell (no Administrator rights required for the task).
# Installs missing free CLI prerequisites via winget/npm only when available.
param([switch]$NoInstall)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function HasCommand([string]$name) { return [bool](Get-Command $name -ErrorAction SilentlyContinue) }
function TryInstall([string]$id) {
  if ($NoInstall) { throw "Required component missing: $id (-NoInstall was specified)." }
  if (-not (HasCommand 'winget')) { throw "Missing $id and winget is unavailable. Install it, then re-run Install.ps1." }
  Write-Host "Installing prerequisite: $id"
  & winget install --id $id --exact --source winget --accept-source-agreements --accept-package-agreements
  if ($LASTEXITCODE -ne 0) { throw "winget failed installing $id. No task was registered." }
  $env:PATH = [Environment]::GetEnvironmentVariable('PATH','Machine') + ';' + [Environment]::GetEnvironmentVariable('PATH','User')
}
function RequireCommand([string]$cmd, [string]$package) {
  if (-not (HasCommand $cmd)) { TryInstall $package }
  if (-not (HasCommand $cmd)) { throw "$cmd still not available; re-open PowerShell after install and rerun this script." }
}

RequireCommand 'git' 'Git.Git'
RequireCommand 'gh' 'GitHub.cli'
RequireCommand 'py' 'Python.Python.3.12'
if (-not (HasCommand 'codex')) {
  RequireCommand 'npm' 'OpenJS.NodeJS.LTS'
  if ($NoInstall) { throw 'Codex CLI missing; install it before using -NoInstall.' }
  & npm install -g '@openai/codex@latest'
  if ($LASTEXITCODE -ne 0) { throw 'Codex CLI install failed.' }
  $env:PATH = [Environment]::GetEnvironmentVariable('PATH','Machine') + ';' + [Environment]::GetEnvironmentVariable('PATH','User')
}
if (-not (HasCommand 'codex')) { throw 'Codex CLI command missing after install. Open new PowerShell and rerun.' }

Write-Host 'Checking GitHub authentication (your own account; no token is requested here).'
& gh auth status *> $null
if ($LASTEXITCODE -ne 0) {
  Write-Host 'One-time GitHub browser authentication required.'
  & gh auth login --hostname github.com --git-protocol https --web
  if ($LASTEXITCODE -ne 0) { throw 'GitHub authentication was not completed.' }
}
& gh auth setup-git
if ($LASTEXITCODE -ne 0) { throw 'Could not configure Git credential helper.' }

Write-Host 'Checking Codex authentication (use ChatGPT Plus login, NOT an API key).'
& codex login status *> $null
if ($LASTEXITCODE -ne 0) {
  Write-Host 'One-time ChatGPT authentication required for Codex CLI.'
  & codex login
  if ($LASTEXITCODE -ne 0) { throw 'Codex authentication was not completed.' }
}

$dest = Join-Path $env:LOCALAPPDATA 'UPSTREAM\CodexBridge\app'
New-Item -ItemType Directory -Force -Path $dest | Out-Null
Copy-Item (Join-Path $PSScriptRoot 'runner.py') (Join-Path $dest 'runner.py') -Force
$configDest = Join-Path $dest 'config.json'
if (-not (Test-Path $configDest)) {
  Copy-Item (Join-Path $PSScriptRoot 'config.example.json') $configDest
}
$pythonExe = (& py -3 -c 'import sys; print(sys.executable)').Trim()
if (-not (Test-Path $pythonExe)) { throw 'Python 3 executable was not found.' }
Write-Host 'Testing GitHub connectivity / tasks (without executing code)...'
& $pythonExe (Join-Path $dest 'runner.py') '--config' $configDest '--dry-run'
if ($LASTEXITCODE -ne 0) { throw 'Dry-run failed. Startup task not registered.' }

$taskName = 'UPSTREAM-Codex-Bridge'
$principalName = $env:USERDOMAIN + '\' + $env:USERNAME
$action = New-ScheduledTaskAction -Execute $pythonExe -Argument ('"{0}" --config "{1}"' -f (Join-Path $dest 'runner.py'), $configDest) -WorkingDirectory $dest
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $principalName
$settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Seconds 0) -MultipleInstances IgnoreNew -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1) -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
$principal = New-ScheduledTaskPrincipal -UserId $principalName -LogonType Interactive -RunLevel Limited
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description 'Poll approved GitHub READY tasks, run sandboxed Codex CLI, create draft PRs; no auto merge/deploy.' -Force | Out-Null
Start-ScheduledTask -TaskName $taskName
Write-Host "Bridge registered and started. Task name: $taskName"
Write-Host "App: $dest"
Write-Host ("Status: " + (Join-Path $env:LOCALAPPDATA 'UPSTREAM\CodexBridge\state.json'))
Write-Host ("Logs: " + (Join-Path $env:LOCALAPPDATA 'UPSTREAM\CodexBridge\bridge.log'))
Write-Host 'The PC must remain powered, connected, signed in, and not asleep. The bridge never merges or deploys.'
