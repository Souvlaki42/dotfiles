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
alias md="mkdir -p"
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
alias bat="batcat"

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
