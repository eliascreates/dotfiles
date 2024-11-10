# PowerShell script to create symlinks
$sourcePath = "$HOME\dotfiles"

# Vim
New-Item -ItemType SymbolicLink -Path "$HOME\_vimrc" -Target "$sourcePath\vim\.vimrc" -Force

# Neovim
New-Item -ItemType SymbolicLink -Path "$HOME\AppData\Local\nvim\init.lua" -Target "$sourcePath\nvim\init.lua" -Force

# VS Code Default Settings
New-Item -ItemType SymbolicLink -Path "$HOME\AppData\Roaming\Code\User\settings.json" -Target "$sourcePath\vscode\settings.json" -Force
New-Item -ItemType SymbolicLink -Path "$HOME\AppData\Roaming\Code\User\keybindings.json" -Target "$sourcePath\vscode\keybindings.json" -Force

# VS Code Profiles
$profilesPath = "$HOME\AppData\Roaming\Code\User\profiles"
if (-Not (Test-Path $profilesPath)) {
    New-Item -ItemType Directory -Path $profilesPath
}
$profileDirs = Get-ChildItem -Path "$sourcePath\vscode\profiles" -Directory
foreach ($profileDir in $profileDirs) {
    $profileName = $profileDir.Name
    New-Item -ItemType SymbolicLink -Path "$profilesPath\$profileName\settings.json" -Target "$sourcePath\vscode\profiles\$profileName\settings.json" -Force
    New-Item -ItemType SymbolicLink -Path "$profilesPath\$profileName\keybindings.json" -Target "$sourcePath\vscode\profiles\$profileName\keybindings.json" -Force
}

# Snippets
New-Item -ItemType SymbolicLink -Path "$HOME\AppData\Roaming\Code\User\snippets" -Target "$sourcePath\vscode\snippets" -Force

# WezTerm
New-Item -ItemType SymbolicLink -Path "$HOME\.wezterm.lua" -Target "$sourcePath\wezterm\.wezterm.lua" -Force

# Oh My Posh
New-Item -ItemType SymbolicLink -Path "$HOME\.poshthemes\theme.omp.json" -Target "$sourcePath\oh-my-posh\theme.omp.json" -Force
New-Item -ItemType SymbolicLink -Path "$HOME\Documents\PowerShell\profile.ps1" -Target "$sourcePath\oh-my-posh\profile.ps1" -Force

# Windows Terminal
New-Item -ItemType SymbolicLink -Path "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" -Target "$sourcePath\windows-terminal\settings.json" -Force

# Git
New-Item -ItemType SymbolicLink -Path "$HOME\.gitconfig" -Target "$sourcePath\git\.gitconfig" -Force
New-Item -ItemType SymbolicLink -Path "$HOME\.gitignore_global" -Target "$sourcePath\git\.gitignore_global" -Force
