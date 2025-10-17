# History configs
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
# Zsh options
setopt correct
setopt nocaseglob
setopt rcexpandparam
setopt nocheckjobs
setopt numericglobsort
setopt nobeep
setopt appendhistory
setopt histignorealldups
setopt autocd
setopt inc_append_history
setopt histignorespace
unsetopt extendedglob
bindkey -v
# The following lines were added by compinstall
zstyle :compinstall filename '/home/nirogu/.zshrc'
autoload -Uz compinit
compinit
# End of lines added by compinstall
# Completion configuration
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' rehash true
zstyle ':completion:*' menu select
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
# Starship prompt and zoxide
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
# Zsh plugins
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# Extend PATH as needed
export PATH=$PATH:/usr/local/bin:$HOME/.local/bin:$HOME/.go/bin:$HOME/.cargo/bin
# Environment variables
export EDITOR=nvim
export VISUAL=$EDITOR
# Aliases
gitup() { git add -A ; git commit -m "$1" ; git push; }
alias cp="cp -i"
alias mkdir="mkdir -p"
alias open="xdg-open"
alias lg="lazygit"
alias cat="bat"
alias ls="eza -1 --icons=auto"
alias ll="eza -lh --icons=auto --sort=name --group-directories-first"
alias la="eza -lha --icons=auto --sort=name --group-directories-first"
alias cd="z"
alias sp="spotify_player"
alias nv="nvim"
alias hx="helix"
please() { sudo $(fc -ln -1) }
