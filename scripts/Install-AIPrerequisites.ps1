<#
Installs system dependencies only — no folder creation.
Requires administrator rights for winget.
#>

# Check admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Administrator rights required for winget installs."
    Write-Host "Right-click PowerShell and select 'Run as Administrator'."
    exit 1
}

Write-Host "Installing prerequisites..."
Write-Host ""

# Track results
$results = @()

# Git
Write-Host "--- Git ---"
$result = winget install Git.Git --accept-source-agreements 2>&1
if ($LASTEXITCODE -eq 0) {
    $results += @{Name="Git"; Status="OK"}
} else {
    $results += @{Name="Git"; Status="FAILED or already installed"}
    Write-Host "$result"
}
Write-Host ""

# Python 3.10
Write-Host "--- Python 3.10 ---"
$result = winget install Python.Python.3.10 --accept-source-agreements 2>&1
if ($LASTEXITCODE -eq 0) {
    $results += @{Name="Python 3.10"; Status="OK"}
} else {
    $results += @{Name="Python 3.10"; Status="FAILED or already installed"}
    Write-Host "$result"
}
Write-Host ""

# Python 3.11
Write-Host "--- Python 3.11 ---"
$result = winget install Python.Python.3.11 --accept-source-agreements 2>&1
if ($LASTEXITCODE -eq 0) {
    $results += @{Name="Python 3.11"; Status="OK"}
} else {
    $results += @{Name="Python 3.11"; Status="FAILED or already installed"}
    Write-Host "$result"
}
Write-Host ""

# Ollama
Write-Host "--- Ollama ---"
$result = winget install Ollama.Ollama --accept-source-agreements 2>&1
if ($LASTEXITCODE -eq 0) {
    $results += @{Name="Ollama"; Status="OK"}
} else {
    $results += @{Name="Ollama"; Status="FAILED or already installed"}
    Write-Host "$result"
}
Write-Host ""

# Summary
Write-Host "========================"
Write-Host "Install Summary"
foreach ($r in $results) {
    Write-Host "  $($r.Name): $($r.Status)"
}
Write-Host "========================"
Write-Host ""
Write-Host "IMPORTANT: Close ALL PowerShell windows, open a new one."
Write-Host "Then verify with:"
Write-Host "  py -0"
Write-Host "  git --version"
Write-Host "  ollama --version"
Write-Host ""
Write-Host "Next step: Restart PowerShell, then run Install-ComfyUI.ps1"
