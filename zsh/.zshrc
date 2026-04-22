# ----------------------------------------
# Profiling
# ----------------------------------------
export PROFILING_MODE=${PROFILING_MODE:-0}
if [[ $PROFILING_MODE -ne 0 ]]; then
  zmodload zsh/zprof
  zsh_start_time=$(date +%s%3N)
fi

# ----------------------------------------
# Environment Variables
# ----------------------------------------
# XDG Base Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# CLI Applications
export BUN_INSTALL="$HOME/.bun"
export GOPATH="$HOME/go"
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
export DEPOT_INSTALL_DIR="$HOME/.depot/bin"

# PATH
export PATH="$HOME/.local/bin:$BUN_INSTALL/bin:$GOPATH/bin:$HOME/.cargo/bin:$DEPOT_INSTALL_DIR:/var/bash.bs:/opt/nvim-linux64/bin:$JAVA_HOME/bin:$HOME/.filen-cli/bin:/snap/bin:$PNPM_HOME:$HOME/matlab:$PATH"

# Shell
export DOTFILES_DIR="$HOME/dotfiles"
export CODE_DIR="$HOME/code"
export NODE_COMPILE_CACHE="$XDG_CACHE_HOME/nodejs-compile-cache"
export VERCEL_TELEMETRY_DISABLED=1
export EDITOR="nvim"
export VISUAL="$EDITOR"
export FILES="dolphin"
export COLORTERM=truecolor
export SSH_ASKPASS="/usr/lib/seahorse/ssh-askpass"
export SSH_ASKPASS_REQUIRE=prefer

# ----------------------------------------
# Fzf Catppuccin theme
# ----------------------------------------
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"


# ----------------------------------------
# Completions
# ----------------------------------------

# FPATH changes before compinit
if [[ ":$FPATH:" != *":$HOME/.zsh/completions:"* ]]; then
  FPATH="$HOME/.zsh/completions:$FPATH"
fi

# Load completion system immediately
ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump"
mkdir -p "${ZSH_COMPDUMP:h}"

autoload -Uz compinit
compinit -d "$ZSH_COMPDUMP" -u

# Completions load after compinit
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# Completion styles
zstyle ":completion:*" auto-description "specify: %d"
zstyle ":completion:*" completer _expand _complete _correct _approximate
zstyle ":completion:*" format "Completing %d"
zstyle ":completion:*" group-name ""
zstyle ":completion:*" menu select=2
zstyle ":completion:*:default" list-colors ${(s.:.)LS_COLORS}
zstyle ":completion:*" matcher-list "" "m:{a-z}={A-Z}" "m:{a-zA-Z}={A-Za-z}" \
  "r:|[._-]=* r:|=* l:|=*"
zstyle ":completion:*" verbose true
zstyle ":completion:*:*:kill:*:processes" \
  list-colors "=(#b) #([0-9]#)*=0=01;31"
zstyle ":completion:*:kill:*" command "ps -u $USER -o pid,%cpu,tty,cputime,cmd"
zstyle ":completion:*" beep no

# ----------------------------------------
# Shell Integrations
# ----------------------------------------
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
eval "$(fnm env --shell zsh)"
eval "$(atuin init zsh)"
eval "$(oh-my-posh init zsh --config "$HOME/shell.toml")"
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"
. "$HOME/.vite-plus/env"

# ----------------------------------------
# Plugin Managers
# ----------------------------------------
typeset -A ZINIT
ZINIT[OPTIMIZE_OUT_DISK_ACCESSES]=1
ZINIT[COMPINIT_OPTS]=-C
ZINIT_HOME="$XDG_DATA_HOME/zinit/zinit.git"
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
zinit light Aloxaf/fzf-tab

# Inject fpath changes before compinit
zinit ice blockf atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions


# These can be deferred as they aren't as critical for the initial interaction
zinit wait lucid for zsh-users/zsh-syntax-highlighting

zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# ----------------------------------------
# Open buffer line in editor
# ----------------------------------------
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey "^x^e" edit-command-line

# ----------------------------------------
# Aliases
# ----------------------------------------
alias cl="tmux clear-history; clear"
alias ls="eza"
alias la="eza -a"
alias ll="eza -alh"
alias tree="eza --tree"
alias md="mkdir -p"
alias v="nvim"
alias c="zeditor"
alias fetch="fastfetch"
alias lg="lazygit"
alias pn="pnpm"
alias python="python3"
alias pip="pip3"
alias history="atuin search -i"
alias yay="paru -Sy --needed"
alias yeet="paru -Runs"
alias packages="cat $DOTFILES_DIR/packages/*.txt"
alias zsh-profile="PROFILING_MODE=1 zsh -i -c exit"

# ----------------------------------------
# functions
# ----------------------------------------
function backupgames() {
  BACKUP_DIR="$HOME/ludusavi-backup"
  DATE=$(date +%Y-%m-%d)

  ludusavi backup --path "$BACKUP_DIR/$DATE" --force

  # Keep only last 7 days of backups
  fd -d 1 -t d --changed-before 7days . "$BACKUP_DIR" -x rm -rf
}

function zsh-audit() {
  echo "precmd:" && print -l $precmd_functions
  echo "preexec:" && print -l $preexec_functions
  echo "duplicates:" && print -l $precmd_functions | sort | uniq -d
}

unalias gcl
function gcl() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: gcl <repo> <optional:name>"
    return 1
  fi

  local repo=$1
  local name=$2
  local last_dir=$(pwd)
  cd "$CODE_DIR"
  sesh clone "$repo" -d "$name"
  cd "$last_dir"
}

function gh-first-commit() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: gh-first-commit <repo>"
    return 1
  fi

  local repo=$1
  local last_page=$(curl -sI "https://api.github.com/repos/$repo/commits?per_page=1" \
    | grep -i '^link:' \
    | grep -oP 'page=\K\d+(?=>; rel="last")')
  local sha=$(curl -s "https://api.github.com/repos/$repo/commits?per_page=1&page=$last_page" \
    | grep -oP '"sha": "\K[^"]+' | head -1)
  echo "https://github.com/$repo/commit/$sha"
}

function man() { command man $@ | bat -l man --style=-numbers }

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
# Vim keybindings for terminal
# ----------------------------------------
bindkey -v

# ----------------------------------------
# Open tmux on startup
# ----------------------------------------
if [ -n "$PS1" ] && [ -z "$TMUX" ]; then
    tmux new-session -A -s main
fi

# ----------------------------------------
# Completion aliases
# ----------------------------------------
if (( $+functions[_paru] )); then
  compdef _paru paru
  compdef _paru yay
  compdef _paru yeet
fi

# ----------------------------------------
# Finalization
# ----------------------------------------
if [[ $PROFILING_MODE -ne 0 ]]; then
  zsh_end_time=$(date +%s%3N)
  zprof
  echo "Shell init time: $((zsh_end_time - zsh_start_time)) ms"
fi
