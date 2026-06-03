<#
AI Control Panel — unified CLI for the AI architecture
Usage:  ai <command> [options]

Commands:
  install <app>      Install an AI application (comfyui, ollama)
  comfyui            Launch ComfyUI
  ollama             Start or check Ollama service
  status             Check system health
  models list        List installed models
  clean cache        Clear temporary files
  help               Show this message
#>

# Detect root — try config first, then common paths, then prompt
$Root = $null
$configCandidates = @("D:\AI\AI_CONFIG\system_config.json", "$env:AI_ROOT\AI_CONFIG\system_config.json")
foreach ($p in $configCandidates) {
    if (Test-Path $p) {
        try { $cfg = Get-Content $p | ConvertFrom-Json; $Root = $cfg.root; break } catch {}
    }
}
if (-not $Root -and (Test-Path "D:\AI")) { $Root = "D:\AI" }
if (-not $Root -and $env:AI_ROOT) { $Root = $env:AI_ROOT }

if (-not $Root) {
    $input = Read-Host "AI root not found. Enter path (e.g. D:\AI)"
    if ([string]::IsNullOrWhiteSpace($input)) {
        Write-Host "Aborted."
        exit 1
    }
    $Root = $input.TrimEnd("\")
}

if (!(Test-Path $Root)) {
    Write-Host "WARNING: $Root does not exist yet. Run 1-init.ps1 first, then try again."
}

$Command = $args[0]
$SubCommand = $args[1]

function Show-Help {
    Write-Host "Usage: ai <command>"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  install comfyui     Install or update ComfyUI"
    Write-Host "  install ollama      Install Ollama via winget"
    Write-Host "  comfyui             Launch ComfyUI"
    Write-Host "  ollama              Start or check Ollama service"
    Write-Host "  status              Check system health"
    Write-Host "  models list         List installed models"
    Write-Host "  clean cache         Delete all temporary files"
    Write-Host "  help                Show this message"
    Write-Host ""
    Write-Host "Root: $Root"
}

function Launch-ComfyUI {
    $launcher = "${Root}\AI_TOOLS\launch_comfyui.ps1"
    if (!(Test-Path $launcher)) {
        Write-Host "ComfyUI not installed. Run: ai install comfyui"
        exit 1
    }
    Write-Host "Starting ComfyUI..."
    & $launcher
}

function Start-Ollama {
    $process = Get-Process -Name "ollama" -ErrorAction SilentlyContinue
    if ($process) {
        Write-Host "Ollama is already running (PID $($process.Id))"
        Write-Host "API: http://localhost:11434"
    } else {
        Write-Host "Starting Ollama service..."
        Start-Process -NoNewWindow -FilePath "ollama" -ArgumentList "serve"
        Write-Host "Ollama started. API: http://localhost:11434"
    }
}

function Get-GPUType {
    # Check for NVIDIA
    $nvidia = Get-WmiObject -Class Win32_VideoController | Where-Object { $_.Name -match "NVIDIA" }
    if ($nvidia) {
        return "nvidia"
    }

    # Check for AMD
    $amd = Get-WmiObject -Class Win32_VideoController | Where-Object { $_.Name -match "AMD|Radeon" }
    if ($amd) {
        return "amd"
    }

    return "unknown"
}

function Install-ComfyUI {
    $ComfyPath = "$Root\AI_CORE\Apps\ComfyUI"
    $gpu = Get-GPUType

    Write-Host "Detected GPU: $gpu"

    if (!(Test-Path $ComfyPath)) {
        Write-Host "Cloning ComfyUI..."
        git clone https://github.com/comfyanonymous/ComfyUI.git "$ComfyPath"
    } else {
        Write-Host "ComfyUI folder exists — pulling latest..."
        Set-Location "$ComfyPath"
        git pull
    }

    Set-Location "$ComfyPath"

    if (!(Test-Path ".\venv")) {
        Write-Host "Creating Python 3.11 environment..."
        py -3.11 -m venv venv
    } else {
        Write-Host "Python environment exists — updating..."
    }

    .\venv\Scripts\Activate.ps1
    pip install --upgrade pip

    # Install requirements but skip torch (handled separately)
    pip install -r requirements.txt --no-deps 2>$null
    pip install -r requirements.txt 2>&1 | Out-Null

    # GPU-specific torch backend
    if ($gpu -eq "amd") {
        Write-Host "AMD GPU detected — installing DirectML backend..."
        pip uninstall torch torchvision torchaudio -y
        pip install torch-directml
    } else {
        Write-Host "NVIDIA GPU detected — using default CUDA torch"
        # torch from requirements.txt is already installed
    }

    deactivate

    # Update config with detected GPU
    $configPath = "$Root\AI_CONFIG\system_config.json"
    if (Test-Path $configPath) {
        $config = Get-Content $configPath | ConvertFrom-Json
        if ($config.gpu -eq "unknown" -and $gpu -ne "unknown") {
            $config.gpu = $gpu
            $config | ConvertTo-Json -Depth 10 | Out-File $configPath
            Write-Host "system_config.json updated: gpu=$gpu"
        }
    }

    # Extra model paths
    $yaml = @"
checkpoints: $Root\AI_VAULT\models\diffusion\checkpoints
loras: $Root\AI_VAULT\models\diffusion\loras
vae: $Root\AI_VAULT\models\diffusion\vae
controlnet: $Root\AI_VAULT\models\diffusion\controlnet
embeddings: $Root\AI_VAULT\models\embeddings
"@
    $yaml | Out-File "$ComfyPath\extra_model_paths.yaml" -Encoding utf8

    # Launcher
    $launcher = @"
Set-Location "$ComfyPath"
.\venv\Scripts\Activate.ps1
python main.py --temp-directory "${Root}\AI_CACHE\comfyui_temp"
"@
    # Ensure target directory exists
    $toolsDir = "${Root}\AI_TOOLS"
    if (!(Test-Path $toolsDir)) { New-Item -ItemType Directory -Path $toolsDir -Force | Out-Null }

    $launcher | Out-File "${Root}\AI_TOOLS\launch_comfyui.ps1" -Encoding utf8

    Write-Host ""
    Write-Host "ComfyUI ready ($gpu). Launch with: .\AI_TOOLS\launch_comfyui.ps1"
}

function Install-Ollama {
    Write-Host "Installing Ollama..."
    winget install Ollama.Ollama --accept-source-agreements
    Write-Host "Done. Restart PowerShell, then set: setx OLLAMA_MODELS `"$Root\AI_CORE\_bindings\llm`""
}

function Show-Status {
    Write-Host "System Status: $Root"
    Write-Host ""

    # Folders
    $layers = @("AI_CONFIG", "AI_CORE", "AI_VAULT", "AI_WORKSPACE", "AI_TOOLS", "AI_CACHE")
    foreach ($layer in $layers) {
        $path = "$Root\$layer"
        if (Test-Path $path) {
            Write-Host "  [OK]  $layer"
        } else {
            Write-Host "  [MISS] $layer"
        }
    }

    Write-Host ""

    # Config
    $configPath = "$Root\AI_CONFIG\system_config.json"
    if (Test-Path $configPath) {
        $config = Get-Content $configPath | ConvertFrom-Json
        $detectedGpu = Get-GPUType
        if ($detectedGpu -ne "unknown") {
            Write-Host "  Config: v$($config.architecture_version) — $detectedGpu GPU"
        } else {
            Write-Host "  Config: v$($config.architecture_version) — $($config.gpu) GPU (run ai install comfyui to auto-detect)"
        }
    } else {
        Write-Host "  Config: missing"
    }

    Write-Host ""

    # Apps
    $comfyPath = "$Root\AI_CORE\Apps\ComfyUI"
    if (Test-Path $comfyPath) {
        Write-Host "  [OK]  ComfyUI"
    } else {
        Write-Host "  [--]  ComfyUI (not installed)"
    }

    # Ollama service
    $ollamaProcess = Get-Process -Name "ollama" -ErrorAction SilentlyContinue
    if ($ollamaProcess) {
        Write-Host "  [OK]  Ollama (running)"
    } else {
        Write-Host "  [--]  Ollama (not running)"
    }

    Write-Host ""

    # Symlinks
    $links = @("llm", "diffusion", "embeddings")
    foreach ($link in $links) {
        $linkPath = "$Root\AI_CORE\_bindings\$link"
        if (Test-Path $linkPath) {
            $target = (Get-Item $linkPath).Target
            Write-Host "  [OK]  _bindings\$link -> $target"
        } else {
            Write-Host "  [MISS] _bindings\$link"
        }
    }
}

function Show-Models {
    # Count models by type
    $diffusionDirs = @("checkpoints", "loras", "vae", "controlnet")
    $llmDir = "$Root\AI_VAULT\models\llm"
    $embedDir = "$Root\AI_VAULT\models\embeddings"

    Write-Host "Installed Models"
    Write-Host ""

    # LLM
    if (Test-Path $llmDir) {
        $count = (Get-ChildItem "$llmDir\*" -Include "*.gguf","*.bin","*.ggml" -ErrorAction SilentlyContinue).Count
        Write-Host "  LLM:           $count models"
    }

    # Diffusion types
    foreach ($dir in $diffusionDirs) {
        $path = "$Root\AI_VAULT\models\diffusion\$dir"
        if (Test-Path $path) {
            $count = @(Get-ChildItem $path -ErrorAction SilentlyContinue).Count
            Write-Host "  Diffusion/${dir}: $count files"
        }
    }

    # Embeddings
    if (Test-Path $embedDir) {
        $count = @(Get-ChildItem $embedDir -ErrorAction SilentlyContinue).Count
        Write-Host "  Embeddings:    $count files"
    }

    # Check registry
    $registryPath = "$Root\AI_CONFIG\model_registry.json"
    if (Test-Path $registryPath) {
        $registry = Get-Content $registryPath | ConvertFrom-Json
        if ($registry.models.Count -gt 0) {
            Write-Host ""
            Write-Host "Registry entries:"
            foreach ($m in $registry.models) {
                Write-Host "  - $($m.name) ($($m.type))"
            }
        }
    }
}

function Clean-Cache {
    $cacheDirs = @(
        "$Root\AI_CACHE\huggingface",
        "$Root\AI_CACHE\torch",
        "$Root\AI_CACHE\comfyui_temp",
        "$Root\AI_CACHE\ollama"
    )

    $total = 0
    foreach ($dir in $cacheDirs) {
        if (Test-Path $dir) {
            $size = (Get-ChildItem $dir -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            $sizeMB = [math]::Round($size / 1MB, 1)
            Remove-Item "$dir\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Cleaned: $dir ($sizeMB MB)"
            $total += $sizeMB
        }
    }

    Write-Host "Total freed: $total MB"
}

# Dispatch
switch ($Command) {
    "install" {
        switch ($SubCommand) {
            "comfyui" { Install-ComfyUI }
            "ollama"  { Install-Ollama }
            default   { Write-Host "Usage: ai install <comfyui|ollama>" }
        }
    }
    "comfyui"    { Launch-ComfyUI }
    "ollama"     { Start-Ollama }
    "status"     { Show-Status }
    "models"     {
        if ($SubCommand -eq "list") { Show-Models }
        else { Write-Host "Usage: ai models list" }
    }
    "clean"      {
        if ($SubCommand -eq "cache") { Clean-Cache }
        else { Write-Host "Usage: ai clean cache" }
    }
    "help"       { Show-Help }
    default      { Show-Help }
}
