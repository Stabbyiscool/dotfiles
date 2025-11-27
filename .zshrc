ZSH_AUTOSUGGEST_USE_ASYNC=1
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source bin/activate 2>/dev/null || true
ZSH_HIGHLIGHT_STYLES[default]='fg=gray'
ZSH_HIGHLIGHT_STYLES[command]='fg=blue'
ZSH_HIGHLIGHT_STYLES[argument]='fg=darkgray'
ZSH_HIGHLIGHT_STYLES[single-char]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[command]='fg=white'
ZSH_HIGHLIGHT_STYLES[operator]='fg=darkgray'
ZSH_HIGHLIGHT_STYLES[brace]='fg=darkgray'
ZSH_HIGHLIGHT_STYLES[back-quote]='fg=darkgray'
ZSH_AUTOSUGGEST_STRATEGY=completion
setopt prompt_subst
PS1='%F{white}%n@%m%f
%F{white}%~%f\$ '

HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=2000

export XDG_CURRENT_DESKTOP=sway
export XDG_PORTAL_BACKEND=wlroots
export GTK_THEME=MonoThemeDark
export RADV_ENABLE_VIDDEC=1
export EDITOR=nano
export TERMINAL=kitty
export PYTHONPATH="$HOME/.pylib:$PYTHONPATH"

export PATH="$HOME/.nimble/bin:$HOME/.local/bin:$PATH"

alias ls='ls --color=auto'
alias la='ls -la'
alias g='git'
alias nano='vim'
alias vp='python ~/Projects/vpli/vpli.py'
alias vpd='python ~/Projects/vpli/vpli.py -d'
alias serve='python3 -m http.server'

setopt autocd
setopt correct
setopt interactive_comments
autoload -Uz compinit && compinit
bindkey '^I' autosuggest-accept
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[OC' forward-word
bindkey '^[OD' backward-word 

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

eval "$(pyenv init --path)"
eval "$(pyenv init -)"
pyenv shell 3.11.2  
