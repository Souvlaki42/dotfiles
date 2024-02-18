# This is the start of my ~/.zshrc configuration file in Arch Linux

# Environment variables
export TERM="xterm-256color"
export MOZ_ENABLE_WAYLAND=1
export DOTFILES_DIR="$HOME/dotfiles"
export PROMPT="%F{blue}%~%f %F{green}>%f "
export EDITOR="nvim"

# Source everything else
source "$DOTFILES_DIR/shell.sh"
