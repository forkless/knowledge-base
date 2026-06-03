<#
2-deps.ps1 — Install system dependencies
Requires administrator rights for winget.
#>

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Administrator rights required for winget installs."
    Write-Host "Right-click PowerShell and select 'Run as Administrator'."
    exit 1
}

Write-Host "Installing prerequisites..."
Write-Host ""

$results = @()

Write-Host "--- Git ---"
$result = winget install Git.Git --accept-source-agreements 2>&1
$results += @{Name="Git"; Status=if ($LASTEXITCODE -eq 0) {"OK"} else {"FAILED or already installed"}}
if ($LASTEXITCODE -ne 0) { Write-Host "$result" }
Write-Host ""

Write-Host "--- Python 3.10 ---"
$result = winget install Python.Python.3.10 --accept-source-agreements 2>&1
$results += @{Name="Python 3.10"; Status=if ($LASTEXITCODE -eq 0) {"OK"} else {"FAILED or already installed"}}
if ($LASTEXITCODE -ne 0) { Write-Host "$result" }
Write-Host ""

Write-Host "--- Python 3.11 ---"
$result = winget install Python.Python.3.11 --accept-source-agreements 2>&1
$results += @{Name="Python 3.11"; Status=if ($LASTEXITCODE -eq 0) {"OK"} else {"FAILED or already installed"}}
if ($LASTEXITCODE -ne 0) { Write-Host "$result" }
Write-Host ""

Write-Host "--- Ollama ---"
$result = winget install Ollama.Ollama --accept-source-agreements 2>&1
$results += @{Name="Ollama"; Status=if ($LASTEXITCODE -eq 0) {"OK"} else {"FAILED or already installed"}}
if ($LASTEXITCODE -ne 0) { Write-Host "$result" }
Write-Host ""

Write-Host "========================"
Write-Host "Install Summary"
foreach ($r in $results) { Write-Host "  $($r.Name): $($r.Status)" }
Write-Host "========================"
Write-Host ""
Write-Host "IMPORTANT: Close ALL PowerShell windows, open a new one."
Write-Host "Then verify with: py -0, git --version, ollama --version"
Write-Host ""
Write-Host "Next step: Restart PowerShell, then run 3-comfyui.ps1"
