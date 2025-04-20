#!/bin/bash

# ─── ENVIRONMENT SETUP ────────────────────────────────────────────────────────

# Windows path detection
# Note: Using $HOME should work in most cases as a simpler alternative
WIN_HOME="$HOME"
# Uncomment below if $HOME doesn't work correctly in your environment
# WIN_HOME=$(powershell.exe -NoProfile -Command "[Environment]::GetFolderPath('UserProfile')" 2>/dev/null | tr -d '\r' | sed 's|\\|/|g')

# Base development directory
DEV_ROOT="/c/dev"

# ─── THEME CONFIGURATION ───────────────────────────────────────────────────────

# Oh-My-Posh setup with fallback
POSH_ROOT="$WIN_HOME/AppData/Local/Programs/oh-my-posh"
POSH_THEMES="$POSH_ROOT/themes"
PRIMARY_THEME="$POSH_THEMES/custom_star.omp.json"
FALLBACK_THEME="$POSH_THEMES/robbyrussell.omp.json"

if [ -f "$PRIMARY_THEME" ]; then
    eval "$(oh-my-posh init bash --config "$PRIMARY_THEME")"
else
    eval "$(oh-my-posh init bash --config "$FALLBACK_THEME")"
fi

# ─── ALIASES ───────────────────────────────────────────────────────────────────

alias ls='lsd'
alias rm='rm -i'
alias activate-venv='source .venv/Scripts/activate'
alias very_good="$HOME/AppData/Local/Pub/Cache/bin/very_good.bat"

# ─── DIRECTORY SHORTCUTS ───────────────────────────────────────────────────────

export dn="$HOME/AppData/Local/nvim"
export dw="$DEV_ROOT"
export dromeo="$DEV_ROOT/work/internal/pod/romeo"

# Personal project directories
export dwf="$DEV_ROOT/personal/flutter"
export dwg="$DEV_ROOT/personal/go"
export dwc="$DEV_ROOT/personal/csharp" 
export dwp="$DEV_ROOT/personal/python"
export dwa="$DEV_ROOT/personal/angular"
export dwj="$DEV_ROOT/personal/java"
export dwo="$DEV_ROOT/personal/other"

# ─── TOOL INTEGRATIONS ─────────────────────────────────────────────────────────

# Load Angular CLI autocompletion only if ng is available
if command -v ng &>/dev/null; then
    source <(ng completion script)
fi

# Zoxide integration if available
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash)"
fi

# ─── UTILITIES ─────────────────────────────────────────────────────────────────

# Yazi file manager helper: updates cwd based on Yazi's output
y() {
    local tmp
    tmp=$(mktemp -t "yazi-cwd.XXXXXX")
    yazi "$@" --cwd-file="$tmp"
    if [[ -s $tmp && "$(cat "$tmp")" != "$PWD" ]]; then
        cd -- "$(cat "$tmp")" || true
    fi
    rm -f -- "$tmp"
}
