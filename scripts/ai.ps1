<#
Ai, ai, ai! Control Panel v1.1 — daily driver for the Ai Bootstrap system
Usage:  ai <command> [options]

Commands:
  install <app>      Install an AI application (comfyui, ollama)
  start <service>    Start a service (ollama, comfyui)
  stop <service>     Stop a service (ollama, comfyui)
  status [service]   System health or specific service status
  models list        List installed models
  clean cache        Clear temporary files
  setup env          Check and fix environment variables (run after install)
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
    Write-Host "===== Ai, ai, ai! Control Panel v1.1 ====="
    Write-Host ""
    Write-Host "Usage: ai <command>"
    Write-Host "Commands:"
    Write-Host "  install comfyui     Install or update ComfyUI"
    Write-Host "  install ollama      Install Ollama via winget"
    Write-Host "  start <service>     Start a service (ollama, comfyui)"
    Write-Host "  stop <service>      Stop a service (ollama, comfyui)"
    Write-Host "  status [service]    System health or specific service status"
    Write-Host "  models list         List installed models"
    Write-Host "  clean cache         Delete all temporary files"
    Write-Host "  setup env           Check and fix environment variables"
    Write-Host "  help                Show this message"
    Write-Host ""
    Write-Host "Root: $Root"
}

function Manage-ComfyUI {
    param([string]$Action)
    $launcher = "${Root}\AI_TOOLS\launch_comfyui.ps1"
    $process = Get-Process -Name "python" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -match "ComfyUI" }
    
    switch ($Action) {
        "start" {
            if ($process) {
                Write-Host "ComfyUI is already running (PID $($process.Id))"
                Write-Host "URL: http://127.0.0.1:8188"
                return
            }
            if (!(Test-Path $launcher)) {
                Write-Host "ComfyUI not installed. Run: ai install comfyui"
                exit 1
            }
            Write-Host "Starting ComfyUI..."
            Start-Process -WindowStyle Hidden -FilePath "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$launcher`""
            Start-Sleep -Seconds 3
            Write-Host "ComfyUI started. URL: http://127.0.0.1:8188"
        }
        "stop" {
            if (-not $process) {
                Write-Host "ComfyUI is not running."
                return
            }
            $process | Stop-Process -Force
            Write-Host "ComfyUI stopped."
        }
        "status" {
            if ($process) {
                Write-Host "ComfyUI: running (PID $($process.Id)) — http://127.0.0.1:8188"
            } else {
                Write-Host "ComfyUI: not running"
            }
        }
    }
}

function Manage-Ollama {
    param([string]$Action)
    $process = Get-Process -Name "ollama" -ErrorAction SilentlyContinue
    
    switch ($Action) {
        "start" {
            if ($process) {
                Write-Host "Ollama is already running (PID $($process.Id))"
                Write-Host "API: http://localhost:11434"
                return
            }
            Write-Host "Starting Ollama in background..."
            Start-Process -WindowStyle Hidden -FilePath "ollama" -ArgumentList "serve"
            Start-Sleep -Seconds 2
            Write-Host "Ollama started. API: http://localhost:11434"
        }
        "stop" {
            if (-not $process) {
                Write-Host "Ollama is not running."
                return
            }
            $process | Stop-Process -Force
            Write-Host "Ollama stopped."
        }
        "status" {
            if ($process) {
                Write-Host "Ollama: running (PID $($process.Id)) — http://localhost:11434"
            } else {
                Write-Host "Ollama: not running"
            }
        }
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

    # Recreate venv if DirectML module is missing (AMD)
    $recreateVenv = $false
    if ((Test-Path ".\venv") -and $gpu -eq "amd") {
        $dmlCheck = & ".\venv\Scripts\python.exe" -c "import torch_directml; print('ok')" 2>$null
        if ($dmlCheck -ne "ok") {
            Write-Host "AMD GPU — DirectML backend not found, recreating venv"
            $recreateVenv = $true
        }
    }
    if ($recreateVenv -or !(Test-Path ".\venv")) {
        if ($recreateVenv) { Remove-Item -Recurse -Force ".\venv" }
        Write-Host "Creating Python 3.11 environment..."
        py -3.11 -m venv venv
    } else {
        Write-Host "Python environment exists — updating..."
    }

    .\venv\Scripts\Activate.ps1

    # Install full requirements (includes torch — needed for non-torch deps)
    pip install -r requirements.txt 2>&1 | Out-Null
    if ($gpu -eq "amd") {
        Write-Host "AMD GPU — adding DirectML backend and fixing audio deps..."
        pip install torch-directml 2>&1 | Out-Null
        pip install torchaudio --force-reinstall 2>&1 | Out-Null
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
vault_config:
    checkpoints: $Root\AI_VAULT\models\diffusion\checkpoints
    loras: $Root\AI_VAULT\models\diffusion\loras
    vae: $Root\AI_VAULT\models\diffusion\vae
    controlnet: $Root\AI_VAULT\models\diffusion\controlnet
    embeddings: $Root\AI_VAULT\models\embeddings
"@
    $yaml | Out-File "$ComfyPath\extra_model_paths.yaml" -Encoding utf8

    # Quick validation
    Write-Host "Validating extra_model_paths.yaml..."
    $yamlLines = Get-Content "$ComfyPath\extra_model_paths.yaml"
    $firstLine = $yamlLines[0].Trim()
    if ($firstLine -match "^[a-zA-Z_]+:$" -and $yamlLines.Count -gt 1 -and $yamlLines[1] -match "^\s+[a-zA-Z_]+:") {
        Write-Host "  OK: named config block detected"
    } else {
        Write-Host "  WARNING: format may be wrong — dumping file:"
        $yamlLines | ForEach-Object { Write-Host "    >$_<" }
        Write-Host "  First line trimmed: '${firstLine}'"
        Write-Host "  Has indent check on line 2: $($yamlLines.Count -gt 1 -and $yamlLines[1] -match '^\s+[a-zA-Z_]+:')"
    }

    # Launcher with GPU flag
    $gpuFlag = if ($gpu -eq "amd") { " --directml" } else { "" }
    $launcher = @"
Set-Location "$ComfyPath"
.\venv\Scripts\Activate.ps1
python main.py --temp-directory "${Root}\AI_CACHE\comfyui_temp"$gpuFlag
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

function Setup-Env {
    Write-Host "Checking environment variables..."
    Write-Host ""

    $vars = @(
        @{Name="OLLAMA_MODELS"; Expected="${Root}\AI_VAULT\models\llm"; Scope="User"; Help="Controls where Ollama stores models. Set before pulling."},
        @{Name="HF_HOME"; Expected="${Root}\AI_CACHE\huggingface"; Scope="User"; Help="Keeps Hugging Face downloads in AI_CACHE, not AI_VAULT."},
        @{Name="TORCH_HOME"; Expected="${Root}\AI_CACHE\torch"; Scope="User"; Help="Keeps PyTorch cache in AI_CACHE, not AI_VAULT."}
    )

    $allOk = $true

    foreach ($v in $vars) {
        $current = [Environment]::GetEnvironmentVariable($v.Name, $v.Scope)
        if ($current -eq $v.Expected) {
            Write-Host "  [OK]  $($v.Name) = $current"
        } elseif ($current) {
            Write-Host "  [MIS] $($v.Name) = $current"
            Write-Host "        Expected: $($v.Expected)"
            Write-Host "        $($v.Help)"
            $choice = Read-Host "        Fix it? (Y/n)"
            if ($choice -ne "n") {
                [Environment]::SetEnvironmentVariable($v.Name, $v.Expected, $v.Scope)
                Write-Host "        Fixed. Restart PowerShell and the service for it to take effect."
            } else {
                $allOk = $false
                Write-Host "        Skipped."
            }
        } else {
            Write-Host "  [MIS] $($v.Name) = (not set)"
            Write-Host "        Expected: $($v.Expected)"
            Write-Host "        $($v.Help)"
            $choice = Read-Host "        Set it now? (Y/n)"
            if ($choice -ne "n") {
                [Environment]::SetEnvironmentVariable($v.Name, $v.Expected, $v.Scope)
                Write-Host "        Set. Restart PowerShell and the service for it to take effect."
            } else {
                $allOk = $false
                Write-Host "        Skipped."
            }
        }
        Write-Host ""
    }

    if (-not $allOk) {
        Write-Host "Some variables were skipped. This may cause issues with model storage and caching."
        exit 1
    }

    Write-Host "All environment variables are correct."
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
    "start"      {
        switch ($SubCommand) {
            "ollama"  { Manage-Ollama "start" }
            "comfyui" { Manage-ComfyUI "start" }
            default   { Write-Host "Usage: ai start <ollama|comfyui>" }
        }
    }
    "stop"      {
        switch ($SubCommand) {
            "ollama"  { Manage-Ollama "stop" }
            "comfyui" { Manage-ComfyUI "stop" }
            default   { Write-Host "Usage: ai stop <ollama|comfyui>" }
        }
    }
    "status"     {
        switch ($SubCommand) {
            "ollama"  { Manage-Ollama "status" }
            "comfyui" { Manage-ComfyUI "status" }
            ""        { Show-Status }
            default   { Write-Host "Usage: ai status [ollama|comfyui]" }
        }
    }
    "models"     {
        if ($SubCommand -eq "list") { Show-Models }
        else { Write-Host "Usage: ai models list" }
    }
    "clean"      {
        if ($SubCommand -eq "cache") { Clean-Cache }
        else { Write-Host "Usage: ai clean cache" }
    }
    "setup"      {
        if ($SubCommand -eq "env") { Setup-Env }
        else { Write-Host "Usage: ai setup env" }
    }
    "help"       { Show-Help }
    default      { Show-Help }
}
