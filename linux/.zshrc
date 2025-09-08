# ----------------------------------------
# Profiling
# ----------------------------------------
export PROFILING_MODE=0
if [[ $PROFILING_MODE -ne 0 ]]; then
  zmodload zsh/zprof
  zsh_start_time=$(date +%s%3N)
fi

# ----------------------------------------
# Environment Variables
# ----------------------------------------
export GOPATH="$HOME/go"
export BUN_INSTALL="$HOME/.bun"
export FNM_PATH="$HOME/.local/share/fnm"
export BREW_PATH="/home/linuxbrew/.linuxbrew/bin"

export PATH="$HOME/.local/bin:$GOPATH/bin:$HOME/.cargo/bin:$BUN_INSTALL/bin:/var/bash.bs:/opt/nvim-linux64/bin:/snap/bin:$FNM_PATH:$BREW_PATH:$PATH"

export NODE_COMPILE_CACHE="$HOME/.cache/nodejs-compile-cache"
export EDITOR="nvim"
export GIT_EDITOR="$EDITOR"
export VISUAL="cursor"
export COLORTERM=truecolor
export HOMEBREW_NO_ENV_HINTS=1

# ----------------------------------------
# Shell Integrations
# ----------------------------------------
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
eval "$(fnm env --shell zsh)"
eval "$(oh-my-posh init zsh --config "$HOME/shell.toml")"
eval "$(atuin init zsh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# ----------------------------------------
# Completions
# ----------------------------------------
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"
if [[ ":$FPATH:" != *":$HOME/.zsh/completions:"* ]]; then
  export FPATH="$HOME/.zsh/completions:$FPATH"
fi

# ----------------------------------------
# Plugin Managers
# ----------------------------------------
typeset -A ZINIT
ZINIT[OPTIMIZE_OUT_DISK_ACCESSES]=1
ZINIT[COMPINIT_OPTS]=-C
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

TPM_HOME="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_HOME" ]]; then
  mkdir -p "$(dirname "$TPM_HOME")"
  git clone https://github.com/tmux-plugins/tpm.git "$TPM_HOME"
  "$TPM_HOME/bin/install_plugins"
fi

# ----------------------------------------
# Zinit Plugins
# ----------------------------------------
# Load these immediately for instant feedback
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search

# These can be deferred as they aren't as critical for the initial interaction
zinit wait lucid for zsh-users/zsh-syntax-highlighting
zinit wait lucid for zsh-users/zsh-completions
zinit wait lucid for Aloxaf/fzf-tab
zinit wait lucid for atuinsh/atuin

zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# ----------------------------------------
# WSL2 Specific Settings
# ----------------------------------------
export BROWSER=xdg-open
eval "$("$HOME/.local/bin/wsl2-ssh-agent")"
export POSH_IS_WSL=1

# ----------------------------------------
# Aliases
# ----------------------------------------
alias cl="tmux clear-history; clear"
alias ls="eza"
alias la="eza -a"
alias ll="eza -alh"
alias tree="eza --tree"
alias md="mkdir"
alias v="$EDITOR"
alias c="$VISUAL"
alias fetch="fastfetch"
alias lg="lazygit"
alias pn="pnpm"
alias python="python3"
alias pip="pip3"
alias gcc="gcc-14"
alias g++="g++-14"
alias history="atuin search -i"

export PNPM_HOME="/home/ilias/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Joke Aliases
alias fsdate='sudo dumpe2fs $(findmnt / -no source) 2>/dev/null | grep "Filesystem created:" | awk "{print \$4, \$5, \$7, \$6}"'
# ----------------------------------------
# History Settings
# ----------------------------------------
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
setopt histignorealldups
setopt EXTENDED_HISTORY

# ----------------------------------------
# Keybindings
# ----------------------------------------
bindkey -v
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# ----------------------------------------
# Completion Styles
# ----------------------------------------
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

# ----------------------------------------
# Finalization
# ----------------------------------------
zinit cdreplay -q

if [[ $PROFILING_MODE -ne 0 ]]; then
  zsh_end_time=$(date +%s%3N)
  zprof
  echo "Shell init time: $((zsh_end_time - zsh_start_time)) ms"
fi
