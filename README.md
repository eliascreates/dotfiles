# 🛠️ dotfiles

These are my personal dotfiles. I set them up to get a dev-ready machine going quickly, mostly on Windows.

## 🧰 What's in here

- Dev tools: VS Code, Neovim, Node.js, Git, PowerShell, Windows Terminal
- Terminals: WezTerm, Git Bash
- Windows tiling setup: GlazeWM + ZeBar, also trying out Komorebi + YASB
- Misc: Zen Browser, Notepad++, Neofetch, and a few CLI tools I like

## ⚙️ Setup

```powershell
.\install.ps1
```

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
├── .gitconfig
├── .gitconfig-personal
├── .gitconfig-work
├── install.ps1
├── applications.yaml
└── README.md
```

---

That’s it. I use this to keep things consistent. If it helps someone else, cool.