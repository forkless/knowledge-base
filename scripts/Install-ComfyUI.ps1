<#
Installs ComfyUI into AI_CORE\Apps
Connects to AI_VAULT via extra model paths
Requires: architecture initialized, prerequisites installed
#>

$Root = Read-Host "Enter AI root path (e.g. D:\AI)"
$Root = $Root.TrimEnd("\")

$ComfyPath = "$Root\AI_CORE\Apps\ComfyUI"

# -------------------------
# CHECK EXECUTION POLICY
# -------------------------

$policy = Get-ExecutionPolicy
if ($policy -eq "Restricted") {
    Write-Host "PowerShell execution policy is Restricted — venv activation will fail."
    $choice = Read-Host "Set to RemoteSigned for current user? (Y/n)"
    if ($choice -ne "n") {
        Set-ExecutionPolicy -Scope CurrentUser RemoteSigned -Force
        Write-Host "Execution policy set to RemoteSigned"
    } else {
        Write-Host "WARNING: venv activation may fail. Re-run with: Set-ExecutionPolicy RemoteSigned"
    }
}

# -------------------------
# CLONE
# -------------------------

if (!(Test-Path $ComfyPath)) {
    Write-Host "Cloning ComfyUI..."
    git clone https://github.com/comfyanonymous/ComfyUI.git "$ComfyPath"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Git clone failed."
        exit 1
    }
} else {
    Write-Host "ComfyUI folder already exists — skipping clone"
}

Set-Location "$ComfyPath"

# -------------------------
# PYTHON ENV
# -------------------------

if (Test-Path ".\venv") {
    Write-Host "Virtual environment already exists — removing and recreating"
    Remove-Item -Recurse -Force ".\venv"
}

Write-Host "Creating Python 3.11 virtual environment..."
$venvResult = py -3.11 -m venv venv 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to create venv — $venvResult"
    Write-Host "Make sure Python 3.11 is installed and the terminal was restarted."
    exit 1
}

$gpu = Get-WmiObject -Class Win32_VideoController | Where-Object { $_.Name -match "NVIDIA" }
if ($gpu) { $gpuType = "nvidia" } else { $gpuType = "amd" }

Write-Host "Detected GPU: $gpuType"

Write-Host "Installing requirements..."
try {
    .\venv\Scripts\Activate.ps1
    pip install --upgrade pip

    # Install all deps except torch (handled per-GPU)
    pip install -r requirements.txt --no-deps 2>$null
    pip install -r requirements.txt 2>&1 | Out-Null

    if ($gpuType -eq "amd") {
        Write-Host "AMD GPU — installing DirectML backend..."
        pip uninstall torch torchvision torchaudio -y
        pip install torch-directml
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Host "WARNING: Some requirements may have failed to install."
    }
} catch {
    Write-Host "ERROR: pip install failed — $_"
    Write-Host "Try running manually: .\venv\Scripts\Activate.ps1 ; pip install -r requirements.txt"
    exit 1
}

# -------------------------
# MODEL PATH CONFIG
# -------------------------

Write-Host "Configuring extra model paths..."
$yaml = @"
checkpoints: $Root\AI_VAULT\models\diffusion\checkpoints
loras: $Root\AI_VAULT\models\diffusion\loras
vae: $Root\AI_VAULT\models\diffusion\vae
controlnet: $Root\AI_VAULT\models\diffusion\controlnet
embeddings: $Root\AI_VAULT\models\embeddings
"@

$yaml | Out-File "$ComfyPath\extra_model_paths.yaml" -Encoding utf8
Write-Host "Created: extra_model_paths.yaml"

# -------------------------
# LAUNCHER
# -------------------------

Write-Host "Creating launcher..."
$launcher = @"
Set-Location "$ComfyPath"
.\venv\Scripts\Activate.ps1
python main.py --temp-directory "$Root\AI_CACHE\comfyui_temp"
"@

$launcher | Out-File "$Root\AI_TOOLS\launch_comfyui.ps1" -Encoding utf8
Write-Host "Created: $Root\AI_TOOLS\launch_comfyui.ps1"

# -------------------------
# SUMMARY
# -------------------------

Write-Host ""
Write-Host "========================"
Write-Host "ComfyUI installation complete"
Write-Host "  Location: $ComfyPath"
Write-Host "  Venv: $ComfyPath\venv (Python 3.11)"
Write-Host "  Model paths: extra_model_paths.yaml"
Write-Host "  Launcher: $Root\AI_TOOLS\launch_comfyui.ps1"
Write-Host "  Temp dir: $Root\AI_CACHE\comfyui_temp"
Write-Host "========================"
Write-Host ""
Write-Host "To launch: .\$Root\AI_TOOLS\launch_comfyui.ps1"
Write-Host "Or navigate to AI_TOOLS and run: .\launch_comfyui.ps1"
