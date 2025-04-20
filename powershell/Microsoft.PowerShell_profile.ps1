$customTheme = "$env:LOCALAPPDATA\Programs\oh-my-posh\themes\custom_atomic.omp.json"
$fallbackTheme = "$env:LOCALAPPDATA\Programs\oh-my-posh\themes\robbyrussell.omp.json"

# Use fallback if custom theme does not exist
$themeToUse = if (Test-Path $customTheme) { $customTheme } else { $fallbackTheme }

oh-my-posh init pwsh --config $themeToUse | Invoke-Expression

Import-Module -Name Terminal-Icons # -ErrorAction SilentlyContinue
Import-Module -Name posh-git # -ErrorAction SilentlyContinue