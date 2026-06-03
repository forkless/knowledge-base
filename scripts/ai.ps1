<#
AI Control Panel — unified CLI for the AI architecture
Usage:  ai <command> [options]

Commands:
  install <app>      Install an AI application (comfyui, ollama)
  status             Check system health
  models list        List installed models
  clean cache        Clear temporary files
  help               Show this message
#>

$Root = if (Test-Path "D:\AI") { "D:\AI" } else { $env:AI_ROOT }

if (-not $Root) {
    Write-Host "ERROR: AI root not found. Set AI_ROOT or run Initialize-AIArchitecture.ps1 first."
    exit 1
}

$Command = $args[0]
$SubCommand = $args[1]

function Show-Help {
    Write-Host "Usage: ai <command>"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  install comfyui     Install or update ComfyUI"
    Write-Host "  install ollama      Install Ollama via winget"
    Write-Host "  status              Check system health"
    Write-Host "  models list         List installed models"
    Write-Host "  clean cache         Delete all temporary files"
    Write-Host "  help                Show this message"
    Write-Host ""
    Write-Host "Root: $Root"
}

function Install-ComfyUI {
    $ComfyPath = "$Root\AI_CORE\Apps\ComfyUI"

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
    }

    .\venv\Scripts\Activate.ps1
    pip install --upgrade pip
    pip install -r requirements.txt
    deactivate

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
python main.py --temp-directory "$Root\AI_CACHE\comfyui_temp"
"@
    $launcher | Out-File "$Root\AI_TOOLS\launch_comfyui.ps1" -Encoding utf8

    Write-Host "ComfyUI ready. Launch with: ai\AI_TOOLS\launch_comfyui.ps1"
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
        Write-Host "  Config: v$($config.architecture_version) — $($config.gpu) GPU"
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
            Write-Host "  Diffusion/$dir: $count files"
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
