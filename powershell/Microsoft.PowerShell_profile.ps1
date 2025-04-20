$customTheme = "C:\Users\USER\AppData\Local\Programs\oh-my-posh\themes\custom_atomic.omp.json"
$fallbackTheme = "C:\Users\USER\AppData\Local\Programs\oh-my-posh\themes\robbyrussell.omp.json"

# Use fallback if custom theme does not exists
$themeToUse = if (Test-Path $customTheme) { $customTheme } else { $fallbackTheme }

oh-my-posh.exe init pwsh --config $themeToUse | Invoke-Expression

Import-Module -Name Terminal-Icons
Import-Module posh-git