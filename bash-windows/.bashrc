eval "$(oh-my-posh init bash --config /c/Users/USER/AppData/Local/Programs/oh-my-posh/themes/atomic.omp.json)"

alias ls='lsd'
alias rm='rm -i'

# Shortcut directory paths
export dn=~/AppData/Local/nvim
export dw=~/../../dev

export dwf=~/../../dev/Personal/flutter/
export dwg=~/../../dev/Personal/go/
export dwc=~/../../dev/Personal/csharp/
export dwp=~/../../dev/Personal/python/
export dwa=~/../../dev/Personal/angular/
export dwj=~/../../dev/Personal/java/

# Load Angular CLI autocompletion.
source <(ng completion script)

# Reset the title to 'Neovim' (or any custom title you want) after loading the script
echo -ne "\033]0;Neovim\007"
