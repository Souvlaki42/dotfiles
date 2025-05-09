# Add deno completions to search path
if [[ ":$FPATH:" != *":$HOME/.zsh/completions:"* ]]; then export FPATH="$HOME/.zsh/completions:$FPATH"; fi

# Make sure WSL2 Ubuntu 24.04 LTS runs under Wayland
ln -sf /mnt/wslg/runtime-dir/wayland-* $XDG_RUNTIME_DIR/

# Configure expected locations
export GOPATH="$HOME/go"
export BUN_INSTALL="$HOME/.bun"
export NVM_DIR="$HOME/.nvm"

# Configure PATH
export PATH="$HOME/.local/bin:$GOPATH/bin:$HOME/.cargo/bin:$BUN_INSTALL/bin:/var/bash.bs:/opt/nvim-linux64/bin:/snap/bin:$PATH"

# Load nvm and its completions
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Export browser in WSL2
export BROWSER=wslview

# Node compile cache
export NODE_COMPILE_CACHE="~/.cache/nodejs-compile-cache"

# Editors
if command -v nvim >/dev/null 2>&1; then
  export EDITOR=nvim
elif command -v vim >/dev/null 2>&1; then
  export EDITOR=vim
elif command -v vi >/dev/null 2>&1; then
  export EDITOR=vi
else
  export EDITOR=nano
fi

export GIT_EDITOR=$EDITOR
export VISUAL="code"

# Enable true color support (16M colors)
export COLORTERM=truecolor

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-history-substring-search
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Aliases
alias cl="clear; tmux clear-history; clear"
alias ls="eza"
alias la="eza -a"
alias ll="eza -alh"
alias tree="eza --tree"
alias md="mkdir"
alias v=$EDITOR
alias c=$VISUAL
alias fetch="fastfetch"
alias lg="lazygit"
alias glo="git log --graph --oneline --decorate"

# Aliases for versioning
alias python="python3"
alias pip="pip3"
alias gcc="gcc-14"
alias g++="g++-14"

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
eval "$(oh-my-posh init zsh --config $HOME/.oh-my-posh.toml)"
eval $(keychain --eval --quiet id_ed25519)

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=$HISTSIZE
HISTFILE=~/.zsh_history
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt histignorealldups sharehistory

# Set up the prompt
autoload -Uz promptinit
promptinit

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e
bindkey "^p" history-search-backward
bindkey "^n" history-search-forward
bindkey "^[w" kill-region

# Use modern completion system
fpath+=~/.zfunc
autoload -Uz compinit
compinit

# Zinit setu
zinit cdreplay -q

# Set up the prompt and completions
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

