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
    $dotfilesRoot = $PSScriptRoot
    # If we're not already in a dotfiles repo (we might be running this script as a one-liner)
    if (Test-Path (Join-Path $dotfilesRoot "applications.yml")) {
        Write-Log "Using local dotfiles in: $dotfilesRoot" -Level "INFO"
        return $dotfilesRoot
    }

    Write-Log "Downloading dotfiles from GitHub..." -Level "INFO"
    $tempZipPath = Join-Path $env:USERPROFILE "dotfiles.zip"
    $dotfilesUrl = "https://github.com/eliascreates/dotfiles/archive/refs/heads/main.zip"
    
    # Download the zip file
    Invoke-WebRequest -Uri $dotfilesUrl -OutFile $tempZipPath
    
    # Create extraction directory
    $extractPath = Join-Path $env:USERPROFILE "dotfiles"
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
    $dotfilesRoot = $extractedDir
    Write-Log "Dotfiles extracted to: $dotfilesRoot" -Level "SUCCESS"
    
    # Clean up the zip file
    Remove-Item -Path $tempZipPath -Force

    return $dotfilesRoot
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
    param(
        [string]$DotfilesRoot
    )
    $platform = Get-Platform
    $wallpapersSrc = Join-Path $DotfilesRoot "Pictures\Wallpapers"

    if(-not $DotfilesRoot) {
        Write-Log "dotfilesRoot is not set" -Level "ERROR"
        return
    }

    Write-Log "dotfilesRoot: $DotfilesRoot" -Level "INFO"
    Write-Log "wallpapaersSrc: $wallpapersSrc" -Level "INFO"
    
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
        $sourceFile = $_.FullName

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
    param(
        [string]$DotfilesRoot
    )
    $platform = Get-Platform
    $applicationsFile = Join-Path $DotfilesRoot "applications.yml"

    if (-not (Test-Path $applicationsFile)) {
        Write-Log "Applications file not found: $applicationsFile" -Level "WARNING"
        return
    }

    try {
        # Install required module for YAML parsing if not already installed
        if (-not (Get-Module -ListAvailable -Name "powershell-yaml")) {
            Write-Log "Installing PowerShell-YAML, Terminal-Icons and posh-git modules..." -Level "INFO"

            Install-Module -Name "powershell-yaml" -Scope CurrentUser -Force
            Install-Module -Name "Terminal-Icons" -Scope CurrentUser -Force
            Install-Module -Name "posh-git" -Scope CurrentUser -Force
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
        [string]$ConfigSubset = "all",
        [string]$DotfilesRoot
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
        "vim",
        "vscode",
        "bash",
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
        $nvimConfigSrc = Join-Path $DotfilesRoot "nvim"
        $nvimConfigDest = Join-Path $HOME "AppData\Local\nvim"
        
        if (-not ($platform -eq "Windows")) {
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
        $poshConfigSrc = Join-Path $DotfilesRoot "oh-my-posh"

        if($env:POSH_THEMES_PATH) {
            $poshConfigDest = $env:POSH_THEMES_PATH
        } else {
            Write-Log "POSH_THEMES_PATH not set. Using default path." -Level "INFO"
            $poshConfigDest = Join-Path $env:LOCALAPPDATA "oh-my-posh\themes"
        }

        if (Test-Path $poshConfigSrc) {
            Initialize-Directory(Split-Path $poshConfigDest -Parent)
            New-SymLink -Source $poshConfigSrc -Target $poshConfigDest -IsDirectory $true
        } else {
            Write-Log "Oh My Posh config source not found: $poshConfigSrc" -Level "WARNING"
        }
    }

    # Vscode configuration
    if ($configsToApply -contains "vscode") {
        Write-Log "Setting up Vscode configuration..." -Level "INFO"
        $vscodeSrc = Join-Path $DotfilesRoot "vscode"
        $vscodeDest = Join-Path $env:APPDATA "Code\User"

        if (Test-Path $vscodeSrc) {
            Initialize-Directory (Split-Path $vscodeDest -Parent)
            New-SymLink -Source $vscodeSrc -Target $vscodeDest -IsDirectory $true
        } else {
            Write-Log "Vscode config source not found: $vscodeSrc" -Level "WARNING"
        }
    }

    # Bash configuration
    if ($configsToApply -contains "bash") {
        Write-Log "Setting up bash configuration..." -Level "INFO"
        $bashSrc = Join-Path $DotfilesRoot "bash\.bashrc"
        $bashDest = Join-Path $HOME ".bashrc"

        if (Test-Path $bashSrc) {
            Initialize-Directory (Split-Path $bashDest -Parent)
            New-SymLink -Source $bashSrc -Target $bashDest
        } else {
            Write-Log "Bash config source not found: $bashSrc" -Level "WARNING"
        }
    }

    # VIM configuration
    if ($configsToApply -contains "vim") {
        Write-Log "Setting up vim configuration..." -Level "INFO"
        $vimSrc = Join-Path $DotfilesRoot "vim\.vimrc"
        $vimDest = Join-Path $HOME ".vimrc"

        if (Test-Path $vimSrc) {
            Initialize-Directory (Split-Path $vimDest -Parent)
            New-SymLink -Source $vimSrc -Target $vimDest
        } else {
            Write-Log "Vim config source not found: $vimSrc" -Level "WARNING"
        }
    }
    
    # WezTerm configuration
    if ($configsToApply -contains "wezterm") {
        Write-Log "Setting up WezTerm configuration..." -Level "INFO"
        $weztermSrc = Join-Path $DotfilesRoot "wezterm\.wezterm.lua"
        $weztermDest = Join-Path $HOME ".wezterm.lua"
        
        if (-not($platform -eq "Windows")) {
            $weztermDest = Join-Path $HOME ".config/.wezterm.lua"
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
        $gitConfigSrc = Join-Path $DotfilesRoot ".git"
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

        $psProfileSrc  = Join-Path $DotfilesRoot "PowerShell\Microsoft.PowerShell_profile.ps1"
        $psProfileDest = $PROFILE

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
        $winTermSrc = Join-Path $DotfilesRoot "WindowsTerminal"
        $winTermDest = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
        if (Test-Path $winTermSrc) {
            Initialize-Directory (Split-Path $winTermDest -Parent)
            New-SymLink -Source $winTermSrc -Target $winTermDest
        } else {
            Write-Log "Windows Terminal settings source not found: $winTermSrc" -Level "WARNING"
        }
    }

    # GlazeWM configuration
    if ($configsToApply -contains "glazewm" -and $platform -eq "Windows") {
        Write-Log "Setting up GlazeWM configuration..." -Level "INFO"
        $glazeConfigSrc = Join-Path $DotfilesRoot ".glzr\glazewm"
        $glazeConfigDest = Join-Path $env:USERPROFILE ".glzr\glazewm"
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
        $komorebiSrc = Join-Path $DotfilesRoot ".config\komorebi.json"
        $komorebiDest = Join-Path $env:USERPROFILE ".config\komorebi\komorebi.json"
        if (Test-Path $komorebiSrc) {
            Initialize-Directory (Split-Path $komorebiDest -Parent)
            New-SymLink -Source $komorebiSrc -Target $komorebiDest
        } else {
            Write-Log "Komorebi config source not found: $komorebiSrc" -Level "WARNING"
        }
    }
    
    # YASB configuration
    if ($configsToApply -contains "yasb" -and $platform -eq "Windows") {
        Write-Log "Setting up YASB configuration..." -Level "INFO"
        $yasbSrc = Join-Path $DotfilesRoot ".config\yasb"
        $yasbDest = Join-Path $HOME ".config\yasb"
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
        $zebarSrc = Join-Path $DotfilesRoot ".glzr\zebar"
        $zebarDest = Join-Path $HOME ".glzr\zebar"
        if (Test-Path $zebarSrc) {
            Initialize-Directory (Split-Path $zebarDest -Parent)
            New-SymLink -Source $zebarSrc -Target $zebarDest -IsDirectory $true
        } else {
            Write-Log "ZeBar config source not found: $zebarSrc" -Level "WARNING"
        }
    }
}

# Set desktop wallpaper (Windows only)
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

# Set lockscreen wallpaper (Windows 10+ only)
function Set-LockScreenWallpaper {
    param(
        [string]$WallpaperPath
    )

    if ((Get-Platform) -eq "Windows") {
        if (Test-Path $WallpaperPath) {
            try {
                # Check if we're on Windows 10 or higher by detecting registry key
                $key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
                
                # Create the key if it doesn't exist
                if (-not (Test-Path $key)) {
                    New-Item -Path $key -Force | Out-Null
                }
                
                # Convert to absolute path and ensure proper formatting
                $absolutePath = [System.IO.Path]::GetFullPath($WallpaperPath)
                
                # Set the properties for lockscreen wallpaper
                New-ItemProperty -Path $key -Name "LockScreenImagePath" -Value $absolutePath -PropertyType String -Force | Out-Null
                New-ItemProperty -Path $key -Name "LockScreenImageUrl" -Value $absolutePath -PropertyType String -Force | Out-Null
                New-ItemProperty -Path $key -Name "LockScreenImageStatus" -Value 1 -PropertyType DWORD -Force | Out-Null
                
                Write-Log "Lock screen wallpaper set to: $WallpaperPath" -Level "SUCCESS"
            } catch {
                Write-Log "Failed to set lock screen wallpaper: $_" -Level "ERROR"
                Write-Log "You may need to set the lock screen wallpaper manually through Windows Settings." -Level "INFO"
            }
        } else {
            Write-Log "Lock screen wallpaper file not found: $WallpaperPath" -Level "WARNING"
        }
    } else {
        Write-Log "Setting lock screen wallpaper is only supported on Windows." -Level "INFO"
    }
}

# Function to clean up temporary files
function Start-Cleanup {
    if (Test-Path (Join-Path $env:USERPROFILE "dotfiles")) {
        Remove-Item -Path (Join-Path $env:USERPROFILE "dotfiles") -Recurse -Force
        Write-Log "Cleaned up temporary files" -Level "INFO"
    }
}

# Installs the NuGet PackageProvider silently if it's missing.
function Install-NugetProvider {
    Write-Log "Ensuring NuGet PackageProvider is present..." -Level "INFO"

    if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
        Write-Log "Installing NuGet provider silently..." -Level "INFO"
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false
        
        Import-PackageProvider -Name NuGet -Force
        Write-Log "NuGet provider installed." -Level "SUCCESS"
    } else {
        Write-Log "NuGet provider already present." -Level "INFO"
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
    Install-NugetProvider
    
    # Initialize dotfiles
    $dotfilesRoot = Initialize-Dotfiles
    
    # Copy wallpapers to Pictures/Wallpapers
    $wallpapersDir = Copy-Wallpapers -DotfilesRoot $dotfilesRoot

    # Set wallpaper if not skipped
    if (-not $SkipWallpaper) {
        # Desktop wallpaper
        $desktopWallpaperName = "panam_1920x1080.png"
        $desktopWallpaperPath = Join-Path $wallpapersDir $desktopWallpaperName
        if (-not (Test-Path $desktopWallpaperPath)) {
            $desktopWallpaperPath = Join-Path $dotfilesRoot "Pictures\Wallpapers\$desktopWallpaperName" 
        }
        
        # Lock screen wallpaper
        $lockscreenWallpaperName = "berk.png"
        $lockscreenWallpaperPath = Join-Path $wallpapersDir $lockscreenWallpaperName
        if (-not (Test-Path $lockscreenWallpaperPath)) {
            $lockscreenWallpaperPath = Join-Path $dotfilesRoot "Pictures\Wallpapers\$lockscreenWallpaperName" 
        }
        
        # Set desktop wallpaper
        if (Test-Path $desktopWallpaperPath) {
            Write-Log "Setting desktop wallpaper..." -Level "INFO"
            Set-Wallpaper -WallpaperPath $desktopWallpaperPath
        } else {
            Write-Log "Desktop wallpaper not found: $desktopWallpaperPath" -Level "WARNING"
        }
        
        # Set lock screen wallpaper
        if (Test-Path $lockscreenWallpaperPath) {
            Write-Log "Setting lock screen wallpaper..." -Level "INFO"
            Set-LockScreenWallpaper -WallpaperPath $lockscreenWallpaperPath
        } else {
            Write-Log "Lock screen wallpaper not found: $lockscreenWallpaperPath" -Level "WARNING"
        }
    } else {
        Write-Log "Skipping wallpaper setup" -Level "INFO"
    }
    
    # Install applications if not skipped
    if (-not $SkipApps) {
        Write-Log "Installing applications..." -Level "INFO"
        Install-Applications -DotfilesRoot $dotfilesRoot
    } else {
        Write-Log "Skipping application installation" -Level "INFO"
    }
    
    # Set app configurations
    Write-Log "Setting up application configurations..." -Level "INFO"
    Set-AppConfigurations -ConfigSubset $ConfigSubset -DotfilesRoot $dotfilesRoot
    
    # Clean up temporary files
    # Start-Cleanup
    Write-Log "Setup complete! You may need to restart some applications for changes to take effect." -Level "SUCCESS"
}

# Run the setup
Start-Setup