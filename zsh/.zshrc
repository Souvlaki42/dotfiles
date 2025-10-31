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
export BUN_INSTALL="$HOME/.bun"
export JAVA_HOME="/usr/lib/jvm/default"
export PATH="$HOME/.local/bin:$BUN_INSTALL/bin:$HOME/.cargo/bin:/var/bash.bs:/opt/nvim-linux64/bin:$HOME/.filen-cli/bin:/snap/bin:$PATH"

export NODE_COMPILE_CACHE="$HOME/.cache/nodejs-compile-cache"
export EDITOR="nvim"
export GIT_EDITOR="$EDITOR"
export VISUAL="zeditor"
export COLORTERM=truecolor
export SHELL=$(which zsh) # Fix Ghostty not using default shell

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
# Shell Integrations
# ----------------------------------------
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
eval "$(fnm env --shell zsh)"
eval "$(oh-my-posh init zsh --config "$HOME/shell.toml")"
eval "$(atuin init zsh)"

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
# Completions
# ----------------------------------------
setopt completealiases
ZSH_COMPDUMP="${XDG_CACHE_HOME:=$HOME/.cache}/zsh/zcompdump"
mkdir -p "${ZSH_COMPDUMP:h}"

# zinit can defer compinit for faster startup
autoload -Uz compinit

# Defer initialization until first completion is used
# -u skips some expensive security checks
# -d points to our stable cache file
zicompinit
zicdreplay -d "$ZSH_COMPDUMP" -u

# Your custom completion sources
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

if [[ ":$FPATH:" != *":$HOME/.zsh/completions:"* ]]; then
  FPATH="$HOME/.zsh/completions:$FPATH"
fi

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
# Zinit Plugins
# ----------------------------------------
# Load these immediately for instant feedback
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab

# These can be deferred as they aren't as critical for the initial interaction
zinit wait lucid for zsh-users/zsh-syntax-highlighting
zinit wait lucid for atuinsh/atuin

zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# ----------------------------------------
# Aliases
# ----------------------------------------
alias cl="tmux clear-history; clear"
alias ls="eza"
alias la="eza -a"
alias ll="eza -alh"
alias tree="eza --tree"
alias md="mkdir -p"
alias v="$EDITOR"
alias c="$VISUAL"
alias fetch="fastfetch"
alias lg="lazygit"
alias pn="pnpm"
alias python="python3"
alias pip="pip3"
alias history="atuin search -i"
alias yay="paru -Sy --needed"
alias yeet="paru -Runs"
alias zed="zeditor"
alias fsdate="sudo sudo btrfs subvolume show / | grep -i \"creation time:\""
alias weather="curl wttr.in"

# Python HTTP Server
function pyhttp() {
  local port=${1:-8080}
  python3 -m http.server $port
}

export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

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
bindkey -M vicmd "k" history-substring-search-up
bindkey -M vicmd "j" history-substring-search-down

# Sesh manager keybinding
function sesh-sessions() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list -t -c -z -d | fzf --height 40% --reverse --border-label " sesh " --border --prompt "⚡  ")
    zle reset-prompt > /dev/null 2>&1 || true
    [[ -z "$session" ]] && return
    sesh connect $session
  }
}

zle     -N             sesh-sessions
bindkey -M emacs "\es" sesh-sessions
bindkey -M vicmd "\es" sesh-sessions
bindkey -M viins "\es" sesh-sessions

# ----------------------------------------
# Finalization
# ----------------------------------------
if [[ $PROFILING_MODE -ne 0 ]]; then
  zsh_end_time=$(date +%s%3N)
  zprof
  echo "Shell init time: $((zsh_end_time - zsh_start_time)) ms"
fi

# bun completions
[ -s "/home/souvlaki42/.bun/_bun" ] && source "/home/souvlaki42/.bun/_bun"
