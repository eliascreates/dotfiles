# 🛠️ dotfiles

These are my personal dotfiles. I set them up to get a dev-ready machine going quickly, mostly on Windows.

## 🧰 What's in here

- Dev tools: VS Code, Neovim, Node.js, Git, PowerShell, Windows Terminal
- Terminals: WezTerm, Git Bash
- Windows tiling setup: GlazeWM + ZeBar, also trying out Komorebi + YASB
- Misc: Zen Browser, Notepad++, Neofetch, and a few CLI tools I like

## ⚙️ Setup

Run locally:
```powershell
.\setup.ps1 [-SkipApps] [-SkipWallpaper] [-ConfigSubset <subset>]
```

### Available switches
- `-SkipApps`        : skips application installation (does not install via winget)
- `-SkipWallpaper`   : skips wallpaper copying and setting
- `-ConfigSubset`    : comma-separated list of configs to apply (default: `all`).
  e.g. `-ConfigSubset neovim,git,powershell`  

Or directly with a one-liner paste in terminal (requires an admin PowerShell prompt):

#### Default (install everything)
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/eliascreates/dotfiles/main/setup.ps1' -OutFile setup.ps1; Unblock-File setup.ps1; ./setup.ps1; Remove-Item setup.ps1"
```

#### Skip only application installation
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/eliascreates/dotfiles/main/setup.ps1' -OutFile setup.ps1; Unblock-File setup.ps1; ./setup.ps1 -SkipApps; Remove-Item setup.ps1"
```

#### Skip only wallpaper step
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/eliascreates/dotfiles/main/setup.ps1' -OutFile setup.ps1; Unblock-File setup.ps1; ./setup.ps1 -SkipWallpaper; Remove-Item setup.ps1"
```

#### Skip both applications and wallpaper
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/eliascreates/dotfiles/main/setup.ps1' -OutFile setup.ps1; Unblock-File setup.ps1; ./setup.ps1 -SkipApps -SkipWallpaper; Remove-Item setup.ps1"
```

#### Apply only a subset of configurations (e.g. `neovim` and `git`)
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/eliascreates/dotfiles/main/setup.ps1' -OutFile setup.ps1; Unblock-File setup.ps1; ./setup.ps1 -ConfigSubset neovim,git; Remove-Item setup.ps1"
```

This approach downloads the script securely, removes the “downloaded from internet” block so it runs under a RemoteSigned policy, executes it with your chosen options, and then cleans up the temp file.

That reads `applications.yml` and installs everything via `winget`.  
If something’s already installed, `winget` skips it.

## 🧠 Git Config Logic Example (For More than 1 Account)

```ini
[include]
    path = ./.gitconfig-personal

[includeIf "gitdir:C:/dev/work/"]
    path = ./.gitconfig-work
```

Default is personal config (`.gitconfig-personal`), unless I’m inside `C:/dev/work/`, then it uses `.gitconfig-work`.

## 📁 Structure

```
dotfiles/
├── .config (nvim, komorebi, yasp, neofetch, etc)
├── .glzr (glazewm, zebar)
├── git
├── powershell
├── wezterm
├── oh-my-posh
├── WindowsTermina
├── vim, bash
├── setup.ps1
└── applications.yml
```

---

That’s it. I use this to keep things consistent. If it helps someone else, cool.
