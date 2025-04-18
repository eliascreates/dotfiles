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

# Download and extract dotfiles if needed
function Initialize-Dotfiles {
    # If we're not already in a dotfiles repo (we might be running this script as a one-liner)
    if (-not (Test-Path (Join-Path $PSScriptRoot "applications.yaml"))) {
        Write-Host "Downloading dotfiles from GitHub..."
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
        Write-Host "Extracting dotfiles..."
        Expand-Archive -Path $tempZipPath -DestinationPath $extractPath -Force
        
        # Find the extracted directory
        $extractedDir = Get-ChildItem -Path $extractPath | Select-Object -First 1 -ExpandProperty FullName
        
        # Set the dotfiles root to the extracted directory
        $global:dotfilesRoot = $extractedDir
        Write-Host "Dotfiles extracted to: $global:dotfilesRoot"
        
        # Clean up the zip file
        Remove-Item -Path $tempZipPath -Force
    } else {
        Write-Host "Using local dotfiles in: $dotfilesRoot"
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

# Copy wallpapers to Pictures/Wallpapers
function Copy-Wallpapers {
    $platform = Get-Platform
    $wallpapersSrc = Join-Path $dotfilesRoot "Pictures" "wallpapers"
    
    if (-not (Test-Path $wallpapersSrc)) {
        Write-Host "Wallpapers directory not found: $wallpapersSrc"
        return
    }
    
    if ($platform -eq "Windows") {
        $wallpapersDest = Join-Path $env:USERPROFILE "Pictures" "Wallpapers"
    } else {
        $wallpapersDest = Join-Path $HOME "Pictures" "Wallpapers"
    }
    
    # Create the destination directory if it doesn't exist
    Initialize-Directory $wallpapersDest
    
    # Copy all wallpapers
    Get-ChildItem -Path $wallpapersSrc -File | ForEach-Object {
        $destFile = Join-Path $wallpapersDest $_.Name
        Copy-Item -Path $_.FullName -Destination $destFile -Force
        Write-Host "Copied wallpaper: $($_.Name) to Pictures/Wallpapers"
    }
    
    return $wallpapersDest
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
    $nvimConfigSrc = Join-Path $dotfilesRoot "AppData" "Local" "nvim"
    
    if ($platform -eq "Windows") {
        $nvimConfigDest = Join-Path $env:LOCALAPPDATA "nvim"
    } else {
        $nvimConfigDest = Join-Path $HOME ".config" "nvim"
    }
    
    if (Test-Path $nvimConfigSrc) {
        Initialize-Directory (Split-Path $nvimConfigDest -Parent)
        New-SymLink -Source $nvimConfigSrc -Target $nvimConfigDest -IsDirectory $true
    } else {
        Write-Host "Neovim config source not found: $nvimConfigSrc" -ForegroundColor Yellow
    }

    Write-Host "Setting up Oh-My-Posh configuration..."
    $poshConfigSrc = Join-Path $dotfilesRoot "oh-my-posh"

    if ($platform -eq "Windows") {
        $poshConfigDest = Join-Path $env:POSH_THEMES_PATH
    } else {
        $poshConfigDest = Join-Path "$HOME" ".local" "bin"
    }

    if (Test-Path $poshConfigSrc) {
        Initialize-Directory(Split-Path $poshConfigDest -Parent)
        New-SymLink -Source $poshConfigSrc -Target $poshConfigDest -IsDirectory $true
    } else {
        Write-Host "Oh My Posh config source not found: $poshConfigSrc" -ForegroundColor Yellow
    }

    # GlazeWM configuration
    if ($platform -eq "Windows") {
        Write-Host "Setting up GlazeWM configuration..."
        $glazeConfigSrc = Join-Path $dotfilesRoot ".config" "glazewm"
        $glazeConfigDest = Join-Path $env:USERPROFILE ".glaze-wm"
        if (Test-Path $glazeConfigSrc) {
            Initialize-Directory (Split-Path $glazeConfigDest -Parent)
            New-SymLink -Source $glazeConfigSrc -Target $glazeConfigDest -IsDirectory $true
        } else {
            Write-Host "GlazeWM config source not found: $glazeConfigSrc" -ForegroundColor Yellow
        }
    }
    
    # Komorebi configuration
    if ($platform -eq "Windows") {
        Write-Host "Setting up Komorebi configuration..."
        $komorebiSrc = Join-Path $dotfilesRoot ".config" "komorebi.json"
        $komorebiDest = Join-Path $env:USERPROFILE ".config" "komorebi" "komorebi.json"
        if (Test-Path $komorebiSrc) {
            Initialize-Directory (Split-Path $komorebiDest -Parent)
            New-SymLink -Source $komorebiSrc -Target $komorebiDest
        } else {
            Write-Host "Komorebi config source not found: $komorebiSrc" -ForegroundColor Yellow
        }
    }
    
    # WezTerm configuration
    Write-Host "Setting up WezTerm configuration..."
    $weztermSrc = Join-Path $dotfilesRoot "wezterm" "wezterm.lua"
    
    if ($platform -eq "Windows") {
        $weztermDest = Join-Path $env:USERPROFILE ".config" "wezterm" "wezterm.lua"
    } else {
        $weztermDest = Join-Path $HOME ".config" "wezterm" "wezterm.lua"
    }
    
    if (Test-Path $weztermSrc) {
        Initialize-Directory (Split-Path $weztermDest -Parent)
        New-SymLink -Source $weztermSrc -Target $weztermDest
    } else {
        Write-Host "WezTerm config source not found: $weztermSrc" -ForegroundColor Yellow
    }
    
    # Git configuration
    Write-Host "Setting up Git configuration..."
    $gitConfigSrc = Join-Path $dotfilesRoot ".gitconfig"
    $gitConfigDest = Join-Path $HOME ".gitconfig"
    if (Test-Path $gitConfigSrc) {
        New-SymLink -Source $gitConfigSrc -Target $gitConfigDest
    } else {
        Write-Host "Git config source not found: $gitConfigSrc" -ForegroundColor Yellow
    }
    
    # PowerShell configuration
    if ($platform -eq "Windows") {
        Write-Host "Setting up PowerShell profile..."
        $psProfileSrc = Join-Path $dotfilesRoot "powershell" "Microsoft.PowerShell_profile.ps1"
        $psProfileDest = Join-Path $env:USERPROFILE "Documents" "PowerShell" "Microsoft.PowerShell_profile.ps1"
        if (Test-Path $psProfileSrc) {
            Initialize-Directory (Split-Path $psProfileDest -Parent)
            New-SymLink -Source $psProfileSrc -Target $psProfileDest
        } else {
            Write-Host "PowerShell profile source not found: $psProfileSrc" -ForegroundColor Yellow
        }
    }
    
    # Windows Terminal settings
    if ($platform -eq "Windows") {
        Write-Host "Setting up Windows Terminal settings..."
        $winTermSrc = Join-Path $dotfilesRoot "WindowsTerminal" "settings.json"
        $winTermDest = Join-Path $env:LOCALAPPDATA "Packages" "Microsoft.WindowsTerminal_8wekyb3d8bbwe" "LocalState" "settings.json"
        if (Test-Path $winTermSrc) {
            Initialize-Directory (Split-Path $winTermDest -Parent)
            New-SymLink -Source $winTermSrc -Target $winTermDest
        } else {
            Write-Host "Windows Terminal settings source not found: $winTermSrc" -ForegroundColor Yellow
        }
    }
    
    # YASB configuration
    if ($platform -eq "Windows") {
        Write-Host "Setting up YASB configuration..."
        $yasbSrc = Join-Path $dotfilesRoot "yasb"
        $yasbDest = Join-Path $env:APPDATA "yasb"
        if (Test-Path $yasbSrc) {
            Initialize-Directory (Split-Path $yasbDest -Parent)
            New-SymLink -Source $yasbSrc -Target $yasbDest -IsDirectory $true
        } else {
            Write-Host "YASB config source not found: $yasbSrc" -ForegroundColor Yellow
        }
    }
    
    # ZeBar configuration
    if ($platform -eq "Windows") {
        Write-Host "Setting up ZeBar configuration..."
        $zebarSrc = Join-Path $dotfilesRoot "zebar"
        $zebarDest = Join-Path $env:APPDATA "zebar"
        if (Test-Path $zebarSrc) {
            Initialize-Directory (Split-Path $zebarDest -Parent)
            New-SymLink -Source $zebarSrc -Target $zebarDest -IsDirectory $true
        } else {
            Write-Host "ZeBar config source not found: $zebarSrc" -ForegroundColor Yellow
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
    
    # Initialize dotfiles
    Initialize-Dotfiles
    
    # Copy wallpapers to Pictures/Wallpapers
    $wallpapersDir = Copy-Wallpapers
    
    # Install applications
    Write-Host "Installing applications..."
    Install-Applications
    
    # Set app configurations
    Write-Host "Setting up application configurations..."
    Set-AppConfigurations
    
    # Set wallpaper if specified
    $wallpaperName = "panam_1920x1080.png"
    $wallpaperPath = Join-Path $wallpapersDir $wallpaperName
    if (-not (Test-Path $wallpaperPath)) {
        $wallpaperPath = Join-Path $dotfilesRoot "Pictures" "Wallpapers" $wallpaperName
    }
    
    if (Test-Path $wallpaperPath) {
        Write-Host "Setting wallpaper..."
        Set-Wallpaper -WallpaperPath $wallpaperPath
    }
    
    Write-Host "Setup complete! You may need to restart some applications for changes to take effect." -ForegroundColor Green
}

# Run the setup
Start-Setup