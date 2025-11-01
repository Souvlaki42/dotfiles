#!/usr/bin/env bash

function yes_or_no() {
  local prompt=$1
  local default=${2-"y"}
  local yn

  while true; do
    read -rp "$prompt [$default]: " yn
    yn="${yn:-$default}"
    case $yn in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *) echo "Please answer yes or no." ;;
    esac
  done
}

function multiselect() {
  local input=("$@")
  local options=()

  if [[ -f "${input[0]}" && ${#input[@]} -eq 1 ]]; then
    mapfile -t options < "${input[0]}"
  else
    options=("${input[@]}")
  fi

  local selected
  selected=$(printf "%s\n" "${options[@]}" | fzf --multi --layout=reverse --bind "ctrl-a:select-all,ctrl-d:deselect-all")

  if [[ -z "$selected" ]]; then
    echo "No options selected. Exiting."
    exit 0
  fi

  mapfile -t selected_array <<< "$selected"

  printf "%s\n" "${selected_array[@]}"
}

echo "Installing necessary packages..."
sudo pacman -Sy --needed --noconfirm fzf stow git base-devel

DOTFILES_DIR="$HOME/dotfiles"

if [[ ! -d "$DOTFILES_DIR" ]]; then
  echo "Dotfiles directory not found. Cloning..."
  git clone https://github.com/souvlaki42/dotfiles "$DOTFILES_DIR"
fi

if ! command -v paru &> /dev/null; then
  echo "Installing paru..."
  paru_dir="${XDG_BIN_HOME:-$HOME/.local/bin}/paru"
  git clone https://aur.archlinux.org/paru.git "$paru_dir"
  cd "$paru_dir" || { echo "Failed to enter paru directory"; exit 1; }
  makepkg -si --noconfirm
  cd "$HOME" ||  { echo "Failed to enter home directory"; exit 1; }
fi

cd "$DOTFILES_DIR" || { echo "Failed to enter dotfiles directory"; exit 1; }

if yes_or_no "Would you like to install packages?" "y"; then
  mapfile -t installed < <(multiselect "./packages/pkg-list-pacman.txt")
  sudo pacman -Sy --needed --noconfirm "${installed[@]}"
fi

if yes_or_no "Would you like to install AUR packages?" "y"; then
  mapfile -t installed < <(multiselect "./packages/pkg-list-aur.txt")
  paru -Sy --needed --noconfirm "${installed[@]}"
fi

symlinks=("atuin" "git" "nvim" "prompt" "tms" "tmux" "zsh" "discord" "themes" "ghostty" "zed" "cava" "pipewire" "applications" "environment" "hollow-knight")
if yes_or_no "Would you like to install symbolic links?" "y"; then
  mapfile -t to_link < <(multiselect "${symlinks[@]}")
  for item in "${to_link[@]}"
  do
    echo "Linking $item..."
    stow -d "$DOTFILES_DIR" -t "$HOME" "$item" || { echo "Failed to link $item"; exit 1; }
  done
fi

if yes_or_no "Would you like to install pacman configuration?" "y"; then
  echo "Installing pacman configuration..."
  sudo stow -d "$DOTFILES_DIR" -t "/" "pacman" || { echo "Failed to link pacman"; exit 1; }
fi

if yes_or_no "Would you like to install sddm configuration?" "y"; then
  echo "Installing sddm configuration..."
  sudo stow -d "$DOTFILES_DIR" -t "/" "sddm" || { echo "Failed to link sddm"; exit 1; }
fi
