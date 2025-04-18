# Dotfiles Setup Script
# Author: eliascreates
# Description: Sets up dotfiles, installs applications, and configures environment

param(
    [switch]$SkipApps,
    [switch]$SkipWallpaper,
    [string]$ConfigSubset = "all"
)

# Script configuration
$ErrorActionPreference = "Stop"
$dotfilesRoot = $PSScriptRoot

# Add a proper logging function
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $colorMap = @{
        "INFO" = "White"
        "SUCCESS" = "Green"
        "WARNING" = "Yellow"
        "ERROR" = "Red"
    }
    
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $colorMap[$Level]
    
    # Optionally log to file
    $logPath = Join-Path $env:TEMP "dotfiles_setup.log"
    "[$timestamp] [$Level] $Message" | Out-File -FilePath $logPath -Append
}

# Check if running as administrator on Windows
function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Detect OS platform
function Get-Platform {
    if ($IsWindows -or $env:OS -match "Windows") {
        return "Windows"
    } elseif ($IsLinux) {
        return "Linux"
    } elseif ($IsMacOS) {
        return "MacOS"
    } else {
        Write-Log "Unable to determine platform. Assuming Windows." -Level "WARNING"
        return "Windows"
    }
}

# Download and extract dotfiles if needed
function Initialize-Dotfiles {
    # If we're not already in a dotfiles repo (we might be running this script as a one-liner)
    if (-not (Test-Path (Join-Path $PSScriptRoot "applications.yaml"))) {
        Write-Log "Downloading dotfiles from GitHub..." -Level "INFO"
        $tempZipPath = Join-Path $env:TEMP "dotfiles.zip"
        $dotfilesUrl = "https://github.com/eliascreates/dotfiles/archive/refs/heads/main.zip"
        
        # Download the zip file
        Invoke-WebRequest -Uri $dotfilesUrl -OutFile $tempZipPath
        
        # Create extraction directory
        $extractPath = Join-Path $env:TEMP "dotfiles-extract"
        if (Test-Path $extractPath) {
            Remove-Item -Path $extractPath -Recurse -Force
        }
        New-Item -ItemType Directory -Path $extractPath -Force | Out-Null
        
        # Extract the zip file
        Write-Log "Extracting dotfiles..." -Level "INFO"
        Expand-Archive -Path $tempZipPath -DestinationPath $extractPath -Force
        
        # Find the extracted directory
        $extractedDir = Get-ChildItem -Path $extractPath | Select-Object -First 1 -ExpandProperty FullName
        
        # Set the dotfiles root to the extracted directory
        $global:dotfilesRoot = $extractedDir
        Write-Log "Dotfiles extracted to: $global:dotfilesRoot" -Level "SUCCESS"
        
        # Clean up the zip file
        Remove-Item -Path $tempZipPath -Force
    } else {
        Write-Log "Using local dotfiles in: $dotfilesRoot" -Level "INFO"
    }
}

# Create a symbolic link
function New-SymLink {
    param(
        [string]$Source,
        [string]$Target,
        [bool]$IsDirectory = $false
    )

    $platform = Get-Platform

    if ($platform -eq "Windows") {
        if (Test-Path $Target) {
            Write-Log "Target already exists: $Target" -Level "WARNING"
            return
        }

        if ($IsDirectory) {
            cmd /c "mklink /D `"$Target`" `"$Source`""
        } else {
            cmd /c "mklink `"$Target`" `"$Source`""
        }
    } else {
        # Linux/MacOS
        if (Test-Path $Target) {
            Write-Log "Target already exists: $Target" -Level "WARNING"
            return
        }
        ln -s "$Source" "$Target"
    }
}

# Initialize directory if it doesn't exist
function Initialize-Directory {
    param(
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Log "Created directory: $Path" -Level "INFO"
    }
}

# Copy wallpapers to Pictures/Wallpapers
function Copy-Wallpapers {
    $platform = Get-Platform
    $wallpapersSrc = Join-Path $dotfilesRoot "Pictures\Wallpapers"
    
    if (-not (Test-Path $wallpapersSrc)) {
        Write-Log "Wallpapers directory not found: $wallpapersSrc" -Level "WARNING"
        return
    }
    
    if ($platform -eq "Windows") {
        $wallpapersDest = Join-Path $env:USERPROFILE "Pictures\Wallpapers"
    } else {
        $wallpapersDest = Join-Path $HOME "Pictures/Wallpapers"
    }
    
    # Create the destination directory if it doesn't exist
    Initialize-Directory $wallpapersDest
    
    # Copy all wallpapers
    Get-ChildItem -Path $wallpapersSrc -File | ForEach-Object {
        $destFile = Join-Path $wallpapersDest $_.Name
        $sourceFile = Copy-Item -Path $_.FullName


        if(Test-Path $destFile) {
            $sourceHash = (Get-FileHash -Path $sourceFile -Algorithm SHA256).Hash
            $destHash = (Get-FileHash -Path $destFile -Algorithm SHA256).Hash

            if($sourceHash -eq $destHash) {
                Write-Log "Skipping $($_.Name) to Pictures/Wallpapers" -Level "INFO"
                return
            }
        }
        Copy-Item -Path $_.FullName -Destination $destFile -Force
        Write-Log "Copied wallpaper: $($_.Name) to Pictures/Wallpapers" -Level "INFO"
    }
    
    return $wallpapersDest
}

# Install applications
function Install-Applications {
    $platform = Get-Platform
    $applicationsFile = Join-Path $dotfilesRoot "applications.yaml"

    if (-not (Test-Path $applicationsFile)) {
        Write-Log "Applications file not found: $applicationsFile" -Level "WARNING"
        return
    }

    try {
        # Install required module for YAML parsing if not already installed
        if (-not (Get-Module -ListAvailable -Name "powershell-yaml")) {
            Write-Log "Installing PowerShell-YAML module..." -Level "INFO"
            Install-Module -Name "powershell-yaml" -Scope CurrentUser -Force
        }

        Import-Module "powershell-yaml"
        $yamlContent = Get-Content -Raw $applicationsFile
        $apps = ConvertFrom-Yaml $yamlContent

        if ($platform -eq "Windows") {
            # Check if winget is available
            $wingetPath = Get-Command winget -ErrorAction SilentlyContinue
            if ($null -eq $wingetPath) {
                Write-Log "Winget not found. Please install it from the Microsoft Store." -Level "ERROR"
                return
            }

            # Install Windows applications from the YAML list
            foreach ($app in $apps.windows) {
                Write-Log "Installing $($app.name)..." -Level "INFO"
                try {
                    winget install --id $app.id -e --accept-source-agreements --accept-package-agreements
                } catch {
                    Write-Log "Failed to install $($app.name): $_" -Level "WARNING"
                    # Continue with next app instead of stopping the script
                }
            }
        } elseif ($platform -eq "Linux") {
            # Handle Linux installations here
            Write-Log "Linux app installation not implemented yet." -Level "INFO"
        } elseif ($platform -eq "MacOS") {
            # Handle MacOS installations here
            Write-Log "MacOS app installation not implemented yet." -Level "INFO"
        }
    } catch {
        Write-Log "Error installing applications: $_" -Level "ERROR"
    }
}

# Configure applications
function Set-AppConfigurations {
    param(
        [string]$ConfigSubset = "all"
    )
    
    $platform = Get-Platform
    $configsToApply = @()
    
    # Define available configurations
    $availableConfigs = @(
        "neovim",
        "oh-my-posh",
        "glazewm",
        "komorebi",
        "wezterm",
        "git",
        "powershell",
        "windows-terminal",
        "yasb",
        "zebar"
    )
    
    # Determine which configs to apply
    if ($ConfigSubset -eq "all") {
        $configsToApply = $availableConfigs
    } else {
        $configsToApply = $ConfigSubset -split ","
    }
    
    Write-Log "Applying configurations: $($configsToApply -join ", ")" -Level "INFO"
    
    # Neovim configuration
    if ($configsToApply -contains "neovim") {
        Write-Log "Setting up Neovim configuration..." -Level "INFO"
        $nvimConfigSrc = Join-Path $dotfilesRoot "AppData\Local\nvim"
        
        if ($platform -eq "Windows") {
            $nvimConfigDest = Join-Path $env:LOCALAPPDATA "nvim"
        } else {
            $nvimConfigDest = Join-Path $HOME ".config/nvim"
        }
        
        if (Test-Path $nvimConfigSrc) {
            Initialize-Directory (Split-Path $nvimConfigDest -Parent)
            New-SymLink -Source $nvimConfigSrc -Target $nvimConfigDest -IsDirectory $true
        } else {
            Write-Log "Neovim config source not found: $nvimConfigSrc" -Level "WARNING"
        }
    }

    # Oh-My-Posh configuration
    if ($configsToApply -contains "oh-my-posh") {
        Write-Log "Setting up Oh-My-Posh configuration..." -Level "INFO"
        $poshConfigSrc = Join-Path $dotfilesRoot "oh-my-posh"

        if ($platform -eq "Windows") {
            $poshConfigDest = Join-Path $env:POSH_THEMES_PATH
        } else {
            $poshConfigDest = Join-Path "$HOME" ".local/bin"
        }

        if (Test-Path $poshConfigSrc) {
            Initialize-Directory(Split-Path $poshConfigDest -Parent)
            New-SymLink -Source $poshConfigSrc -Target $poshConfigDest -IsDirectory $true
        } else {
            Write-Log "Oh My Posh config source not found: $poshConfigSrc" -Level "WARNING"
        }
    }

    # GlazeWM configuration
    if ($configsToApply -contains "glazewm" -and $platform -eq "Windows") {
        Write-Log "Setting up GlazeWM configuration..." -Level "INFO"
        $glazeConfigSrc = Join-Path $dotfilesRoot ".config\glazewm"
        $glazeConfigDest = Join-Path $env:USERPROFILE ".glaze-wm"
        if (Test-Path $glazeConfigSrc) {
            Initialize-Directory (Split-Path $glazeConfigDest -Parent)
            New-SymLink -Source $glazeConfigSrc -Target $glazeConfigDest -IsDirectory $true
        } else {
            Write-Log "GlazeWM config source not found: $glazeConfigSrc" -Level "WARNING"
        }
    }
    
    # Komorebi configuration
    if ($configsToApply -contains "komorebi" -and $platform -eq "Windows") {
        Write-Log "Setting up Komorebi configuration..." -Level "INFO"
        $komorebiSrc = Join-Path $dotfilesRoot ".config" "komorebi.json"
        $komorebiDest = Join-Path $env:USERPROFILE ".config\komorebi\komorebi.json"
        if (Test-Path $komorebiSrc) {
            Initialize-Directory (Split-Path $komorebiDest -Parent)
            New-SymLink -Source $komorebiSrc -Target $komorebiDest
        } else {
            Write-Log "Komorebi config source not found: $komorebiSrc" -Level "WARNING"
        }
    }
    
    # WezTerm configuration
    if ($configsToApply -contains "wezterm") {
        Write-Log "Setting up WezTerm configuration..." -Level "INFO"
        $weztermSrc = Join-Path $dotfilesRoot "wezterm" "wezterm.lua"
        
        if ($platform -eq "Windows") {
            $weztermDest = Join-Path $env:USERPROFILE ".config\wezterm\wezterm.lua"
        } else {
            $weztermDest = Join-Path $HOME ".config/wezterm/wezterm.lua"
        }
        
        if (Test-Path $weztermSrc) {
            Initialize-Directory (Split-Path $weztermDest -Parent)
            New-SymLink -Source $weztermSrc -Target $weztermDest
        } else {
            Write-Log "WezTerm config source not found: $weztermSrc" -Level "WARNING"
        }
    }
    
    # Git configuration
    if ($configsToApply -contains "git") {
        Write-Log "Setting up Git configuration..." -Level "INFO"
        $gitConfigSrc = Join-Path $dotfilesRoot ".gitconfig"
        $gitConfigDest = Join-Path $HOME ".gitconfig"
        if (Test-Path $gitConfigSrc) {
            New-SymLink -Source $gitConfigSrc -Target $gitConfigDest
        } else {
            Write-Log "Git config source not found: $gitConfigSrc" -Level "WARNING"
        }
    }
    
    # PowerShell configuration
    if ($configsToApply -contains "powershell" -and $platform -eq "Windows") {
        Write-Log "Setting up PowerShell profile..." -Level "INFO"
        $psProfileSrc = Join-Path $dotfilesRoot "powershell\Microsoft.PowerShell_profile.ps1"
        $psProfileDest = Join-Path $env:USERPROFILE "Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
        if (Test-Path $psProfileSrc) {
            Initialize-Directory (Split-Path $psProfileDest -Parent)
            New-SymLink -Source $psProfileSrc -Target $psProfileDest
        } else {
            Write-Log "PowerShell profile source not found: $psProfileSrc" -Level "WARNING"
        }
    }
    
    # Windows Terminal settings
    if ($configsToApply -contains "windows-terminal" -and $platform -eq "Windows") {
        Write-Log "Setting up Windows Terminal settings..." -Level "INFO"
        $winTermSrc = Join-Path $dotfilesRoot "WindowsTerminal\settings.json"
        $winTermDest = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        if (Test-Path $winTermSrc) {
            Initialize-Directory (Split-Path $winTermDest -Parent)
            New-SymLink -Source $winTermSrc -Target $winTermDest
        } else {
            Write-Log "Windows Terminal settings source not found: $winTermSrc" -Level "WARNING"
        }
    }
    
    # YASB configuration
    if ($configsToApply -contains "yasb" -and $platform -eq "Windows") {
        Write-Log "Setting up YASB configuration..." -Level "INFO"
        $yasbSrc = Join-Path $dotfilesRoot "yasb"
        $yasbDest = Join-Path $env:APPDATA "yasb"
        if (Test-Path $yasbSrc) {
            Initialize-Directory (Split-Path $yasbDest -Parent)
            New-SymLink -Source $yasbSrc -Target $yasbDest -IsDirectory $true
        } else {
            Write-Log "YASB config source not found: $yasbSrc" -Level "WARNING"
        }
    }
    
    # ZeBar configuration
    if ($configsToApply -contains "zebar" -and $platform -eq "Windows") {
        Write-Log "Setting up ZeBar configuration..." -Level "INFO"
        $zebarSrc = Join-Path $dotfilesRoot "zebar"
        $zebarDest = Join-Path $env:APPDATA "zebar"
        if (Test-Path $zebarSrc) {
            Initialize-Directory (Split-Path $zebarDest -Parent)
            New-SymLink -Source $zebarSrc -Target $zebarDest -IsDirectory $true
        } else {
            Write-Log "ZeBar config source not found: $zebarSrc" -Level "WARNING"
        }
    }
}

# Set wallpaper (Windows only)
function Set-Wallpaper {
    param(
        [string]$WallpaperPath
    )

    if ((Get-Platform) -eq "Windows") {
        if (Test-Path $WallpaperPath) {
            $code = @'
            using System.Runtime.InteropServices;
            
            public class Wallpaper {
                [DllImport("user32.dll", CharSet = CharSet.Auto)]
                public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
                
                public static void SetWallpaper(string path) {
                    SystemParametersInfo(20, 0, path, 3);
                }
            }
'@
            Add-Type -TypeDefinition $code
            [Wallpaper]::SetWallpaper($WallpaperPath)
            Write-Log "Wallpaper set to: $WallpaperPath" -Level "SUCCESS"
        } else {
            Write-Log "Wallpaper file not found: $WallpaperPath" -Level "WARNING"
        }
    } else {
        Write-Log "Setting wallpaper is only supported on Windows." -Level "INFO"
    }
}

# Function to clean up temporary files
function Start-Cleanup {
    if (Test-Path (Join-Path $env:TEMP "dotfiles-extract")) {
        Remove-Item -Path (Join-Path $env:TEMP "dotfiles-extract") -Recurse -Force
        Write-Log "Cleaned up temporary files" -Level "INFO"
    }
}

# Main setup function
function Start-Setup {
    Write-Log "Starting dotfiles setup script" -Level "INFO"
    $platform = Get-Platform
    Write-Log "Detected platform: $platform" -Level "INFO"
    
    # Check for administrator rights on Windows
    if ($platform -eq "Windows" -and -not (Test-Administrator)) {
        Write-Log "This script requires administrator privileges. Please run as administrator." -Level "ERROR"
        return
    }
    
    # Initialize dotfiles
    Initialize-Dotfiles
    
    # Copy wallpapers to Pictures/Wallpapers
    $wallpapersDir = Copy-Wallpapers
    
    # Install applications if not skipped
    if (-not $SkipApps) {
        Write-Log "Installing applications..." -Level "INFO"
        Install-Applications
    } else {
        Write-Log "Skipping application installation" -Level "INFO"
    }
    
    # Set app configurations
    Write-Log "Setting up application configurations..." -Level "INFO"
    Set-AppConfigurations -ConfigSubset $ConfigSubset
    
    # Set wallpaper if not skipped
    if (-not $SkipWallpaper) {
        $wallpaperName = "panam_1920x1080.png"
        $wallpaperPath = Join-Path $wallpapersDir $wallpaperName
        if (-not (Test-Path $wallpaperPath)) {
            $wallpaperPath = Join-Path $dotfilesRoot "Pictures\Wallpapers\$wallpaperName" 
        }
        
        if (Test-Path $wallpaperPath) {
            Write-Log "Setting wallpaper..." -Level "INFO"
            Set-Wallpaper -WallpaperPath $wallpaperPath
        }
    } else {
        Write-Log "Skipping wallpaper setup" -Level "INFO"
    }
    
    # Clean up temporary files
    Start-Cleanup
    
    Write-Log "Setup complete! You may need to restart some applications for changes to take effect." -Level "SUCCESS"
}

# Run the setup
Start-Setup