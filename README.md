# 🛠️ dotfiles

These are my personal dotfiles. I set them up to get a dev-ready machine going quickly, mostly on Windows.

## 🧰 What's in here

- Dev tools: VS Code, Neovim, Node.js, Git, PowerShell, Windows Terminal
- Terminals: WezTerm, Git Bash
- Windows tiling setup: GlazeWM + ZeBar, also trying out Komorebi + YASB
- Misc: Zen Browser, Notepad++, Neofetch, and a few CLI tools I like

## ⚙️ Setup

locally

```powershell
.\setup.ps1
```

Or directly with a one-liner paste in terminal (requires an admin PowerShell prompt):
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "$t = New-TemporaryFile; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/eliascreates/dotfiles/main/setup.ps1' -OutFile $t; Unblock-File $t; & $t; Remove-Item $t"
```
This approach downloads the script securely, removes the “downloaded from internet” block so it runs under a RemoteSigned policy, executes it, and then cleans up the temp file.

That reads `applications.yaml` and installs everything via `winget`.  
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
└── applications.yaml
```

---

That’s it. I use this to keep things consistent. If it helps someone else, cool.