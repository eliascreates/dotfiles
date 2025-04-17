# Dotfiles Setup Script
# Author: eliascreates
# Description: Sets up dotfiles, installs applications, and configures environment

# Script configuration
$ErrorActionPreference = "Stop"
$dotfilesRoot = $PSScriptRoot

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
        Write-Host "Unable to determine platform. Assuming Windows."
        return "Windows"
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
            Write-Host "Target already exists: $Target"
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
            Write-Host "Target already exists: $Target"
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
        Write-Host "Created directory: $Path"
    }
}

# Install applications
function Install-Applications {
    $platform = Get-Platform
    $applicationsFile = Join-Path $dotfilesRoot "applications.yaml"

    if (-not (Test-Path $applicationsFile)) {
        Write-Host "Applications file not found: $applicationsFile"
        return
    }

    try {
        # Install required module for YAML parsing if not already installed
        if (-not (Get-Module -ListAvailable -Name "powershell-yaml")) {
            Write-Host "Installing PowerShell-YAML module..."
            Install-Module -Name "powershell-yaml" -Scope CurrentUser -Force
        }

        Import-Module "powershell-yaml"
        $yamlContent = Get-Content -Raw $applicationsFile
        $apps = ConvertFrom-Yaml $yamlContent

        if ($platform -eq "Windows") {
            # Check if winget is available
            $wingetPath = Get-Command winget -ErrorAction SilentlyContinue
            if ($null -eq $wingetPath) {
                Write-Host "Winget not found. Please install it from the Microsoft Store."
                return
            }

            # Install Windows applications from the YAML list
            foreach ($app in $apps.windows) {
                Write-Host "Installing $($app.name)..."
                try {
                    winget install --id $app.id -e --accept-source-agreements --accept-package-agreements
                } catch {
                    Write-Host "Failed to install $($app.name): $_" -ForegroundColor Yellow
                    # Continue with next app instead of stopping the script
                }
            }
        } elseif ($platform -eq "Linux") {
            # Handle Linux installations here (if you use Linux in the future)
            Write-Host "Linux app installation not implemented yet."
        } elseif ($platform -eq "MacOS") {
            # Handle MacOS installations here (if you use MacOS in the future)
            Write-Host "MacOS app installation not implemented yet."
        }
    } catch {
        Write-Host "Error installing applications: $_"
    }
}

# Configure applications
function Set-AppConfigurations {
    $platform = Get-Platform
    
    # Neovim configuration
    Write-Host "Setting up Neovim configuration..."
    $nvimConfigSrc = Join-Path $dotfilesRoot ".config" "nvim"
    
    if ($platform -eq "Windows") {
        $nvimConfigDest = Join-Path $env:LOCALAPPDATA "nvim"
    } else {
        $nvimConfigDest = Join-Path $HOME ".config" "nvim"
    }
    
    Initialize-Directory (Split-Path $nvimConfigDest -Parent)
    New-SymLink -Source $nvimConfigSrc -Target $nvimConfigDest -IsDirectory $true
    
    # GlazeWM configuration
    if ($platform -eq "Windows") {
        Write-Host "Setting up GlazeWM configuration..."
        $glazeConfigSrc = Join-Path $dotfilesRoot ".config" "glazewm"
        $glazeConfigDest = Join-Path $env:USERPROFILE ".glaze-wm"
        Initialize-Directory (Split-Path $glazeConfigDest -Parent)
        New-SymLink -Source $glazeConfigSrc -Target $glazeConfigDest -IsDirectory $true
    }
    
    # Komorebi configuration
    if ($platform -eq "Windows") {
        Write-Host "Setting up Komorebi configuration..."
        $komorebiSrc = Join-Path $dotfilesRoot "komorebi.json"
        $komorebiDest = Join-Path $env:USERPROFILE ".config" "komorebi" "komorebi.json"
        Initialize-Directory (Split-Path $komorebiDest -Parent)
        New-SymLink -Source $komorebiSrc -Target $komorebiDest
    }
    
    # WezTerm configuration
    Write-Host "Setting up WezTerm configuration..."
    $weztermSrc = Join-Path $dotfilesRoot "wezterm" "wezterm.lua"
    
    if ($platform -eq "Windows") {
        $weztermDest = Join-Path $env:USERPROFILE ".config" "wezterm" "wezterm.lua"
    } else {
        $weztermDest = Join-Path $HOME ".config" "wezterm" "wezterm.lua"
    }
    
    Initialize-Directory (Split-Path $weztermDest -Parent)
    New-SymLink -Source $weztermSrc -Target $weztermDest
    
    # Git configuration
    Write-Host "Setting up Git configuration..."
    $gitConfigSrc = Join-Path $dotfilesRoot ".gitconfig"
    $gitConfigDest = Join-Path $HOME ".gitconfig"
    New-SymLink -Source $gitConfigSrc -Target $gitConfigDest
    
    # PowerShell configuration
    if ($platform -eq "Windows") {
        Write-Host "Setting up PowerShell profile..."
        $psProfileSrc = Join-Path $dotfilesRoot "powershell" "Microsoft.PowerShell_profile.ps1"
        $psProfileDest = Join-Path $env:USERPROFILE "Documents" "PowerShell" "Microsoft.PowerShell_profile.ps1"
        Initialize-Directory (Split-Path $psProfileDest -Parent)
        New-SymLink -Source $psProfileSrc -Target $psProfileDest
    }
    
    # Windows Terminal settings
    if ($platform -eq "Windows") {
        Write-Host "Setting up Windows Terminal settings..."
        $winTermSrc = Join-Path $dotfilesRoot "WindowsTerminal" "settings.json"
        $winTermDest = Join-Path $env:LOCALAPPDATA "Packages" "Microsoft.WindowsTerminal_8wekyb3d8bbwe" "LocalState" "settings.json"
        Initialize-Directory (Split-Path $winTermDest -Parent)
        New-SymLink -Source $winTermSrc -Target $winTermDest
    }
    
    # YASB configuration
    if ($platform -eq "Windows") {
        Write-Host "Setting up YASB configuration..."
        $yasbSrc = Join-Path $dotfilesRoot "yasb"
        $yasbDest = Join-Path $env:APPDATA "yasb"
        Initialize-Directory (Split-Path $yasbDest -Parent)
        New-SymLink -Source $yasbSrc -Target $yasbDest -IsDirectory $true
    }
    
    # ZeBar configuration
    if ($platform -eq "Windows") {
        Write-Host "Setting up ZeBar configuration..."
        $zebarSrc = Join-Path $dotfilesRoot "zebar"
        $zebarDest = Join-Path $env:APPDATA "zebar"
        Initialize-Directory (Split-Path $zebarDest -Parent)
        New-SymLink -Source $zebarSrc -Target $zebarDest -IsDirectory $true
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
            Write-Host "Wallpaper set to: $WallpaperPath"
        } else {
            Write-Host "Wallpaper file not found: $WallpaperPath"
        }
    } else {
        Write-Host "Setting wallpaper is only supported on Windows."
    }
}

# Main setup function
function Start-Setup {
    $platform = Get-Platform
    Write-Host "Detected platform: $platform"
    
    # Check for administrator rights on Windows
    if ($platform -eq "Windows" -and -not (Test-Administrator)) {
        Write-Host "This script requires administrator privileges. Please run as administrator." -ForegroundColor Red
        return
    }
    
    # Install applications
    Write-Host "Installing applications..."
    Install-Applications
    
    # Set app configurations
    Write-Host "Setting up application configurations..."
    Set-AppConfigurations
    
    # Set wallpaper if specified
    $wallpaperPath = Join-Path $dotfilesRoot "wallpapers" "default.jpg"
    if (Test-Path $wallpaperPath) {
        Write-Host "Setting wallpaper..."
        Set-Wallpaper -WallpaperPath $wallpaperPath
    }
    
    Write-Host "Setup complete! You may need to restart some applications for changes to take effect." -ForegroundColor Green
}

# Run the setup
Start-Setup