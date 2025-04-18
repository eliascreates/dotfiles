# Dynamically detect Windows user profile in Bash
# Works in Git Bash or WSL if PowerShell is available
WIN_HOME=$(powershell.exe -NoProfile -Command "[Environment]::GetFolderPath('UserProfile')" \
    | tr -d '\r' \
    | sed 's|\\|/|g')

# Oh‑My‑Posh setup
POSH_ROOT="$WIN_HOME/AppData/Local/Programs/oh-my-posh"
POSH_THEMES="$POSH_ROOT/themes"

eval "$(oh-my-posh init bash --config "$POSH_THEMES/atomic.omp.json")"
eval "$(oh-my-posh init bash --config "$POSH_THEMES/custom_star.omp.json")"
# To add more themes, just duplicate the line above with a new theme file.

# Core aliases
alias ls='lsd'
alias rm='rm -i'
alias activate-venv='source .venv/Scripts/activate'
alias very_good="$HOME/AppData/Local/Pub/Cache/bin/very_good.bat"

# Base development directory
DEV_ROOT="/c/dev"

# Shortcut directory paths
export dn="$HOME/AppData/Local/nvim"
export dw="$DEV_ROOT"

export dromeo="$DEV_ROOT/work/internal/pod/romeo"
export dwf="$DEV_ROOT/personal/flutter"
export dwg="$DEV_ROOT/personal/go"
export dwc="$DEV_ROOT/personal/csharp"
export dwp="$DEV_ROOT/personal/python"
export dwa="$DEV_ROOT/personal/angular"
export dwj="$DEV_ROOT/personal/java"
export dwo="$DEV_ROOT/personal/other"

# Load Angular CLI autocompletion
source <(ng completion script)

# Yazi helper: updates cwd based on Yazi’s output
y() {
    local tmp
    tmp=$(mktemp -t "yazi-cwd.XXXXXX")
    yazi "$@" --cwd-file="$tmp"
    if [[ -s $tmp && "$(cat "$tmp")" != "$PWD" ]]; then
        cd -- "$(cat "$tmp")" || true
    fi
    rm -f -- "$tmp"
}

# Zoxide integration
eval "$(zoxide init bash)"
