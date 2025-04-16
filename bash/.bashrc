# eval "$(oh-my-posh init bash --config /c/Users/USER/AppData/Local/Programs/oh-my-posh/themes/atomic.omp.json)"
eval "$(oh-my-posh init bash --config /c/Users/USER/AppData/Local/Programs/oh-my-posh/themes/custom_star.omp.json)"

# eval "$(oh-my-posh init bash --config /c/Users/USER/AppData/Local/Programs/oh-my-posh/themes/pararussel.omp.json)"
alias ls='lsd'
alias rm='rm -i'
alias activate-venv='source .venv/Scripts/activate'
alias very_good="$HOME/AppData/Local/Pub/Cache/bin/very_good.bat"

# Shortcut directory paths
export dn=~/AppData/Local/nvim
export dw=/c/dev

export dromeo=/c/dev/work/internal/pod/romeo
export dwf=/c/dev/personal/flutter
export dwg=/c/dev/personal/go
export dwc=/c/dev/personal/csharp
export dwp=/c/dev/personal/python
export dwa=/c/dev/personal/angular
export dwj=/c/dev/personal/java
export dwo=/c/dev/personal/other

# Load Angular CLI autocompletion.
source <(ng completion script)

# Reset the title to 'Neovim' (or any custom title you want) after loading the script
# echo -ne "\033]0;Neovim\007"

# Yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Zoxide
eval "$(zoxide init bash)"
