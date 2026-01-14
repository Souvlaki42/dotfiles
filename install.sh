#!/usr/bin/env bash

trap "echo -e '\nCanceling installation...'; exit 130" INT

ACCEPT_ALL=false
if [[ "$1" == "--yes" || "$1" == "-y" ]]; then
  ACCEPT_ALL=true
fi

function yes_or_no() {
  if [[ "$ACCEPT_ALL" == true ]]; then
    echo "$1 [auto-yes]"
    return 0
  fi

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

echo "Default AUR helper is paru. Installing..."

if ! command -v paru &> /dev/null; then
  echo "Installing paru..."
  paru_dir="${XDG_BIN_HOME:-$HOME/.local/bin}/paru"
  git clone https://aur.archlinux.org/paru.git "$paru_dir"
  cd "$paru_dir" || { echo "Failed to enter paru directory"; exit 1; }
  makepkg -si --noconfirm
  cd "$HOME" ||  { echo "Failed to enter home directory"; exit 1; }
  rm -rf "$paru_dir" || { echo "Failed to remove paru directory"; exit 1; }
fi

if yes_or_no "Would you like to also install yay?" "y"; then
  echo "Installing yay..."
  yay_dir="${XDG_BIN_HOME:-$HOME/.local/bin}/yay"
  git clone https://aur.archlinux.org/yay.git "$yay_dir"
  cd "$yay_dir" || { echo "Failed to enter yay directory"; exit 1; }
  makepkg -si --noconfirm
  cd "$HOME" ||  { echo "Failed to enter home directory"; exit 1; }
  rm -rf "$yay_dir" || { echo "Failed to remove yay directory"; exit 1; }
fi

cd "$DOTFILES_DIR" || { echo "Failed to enter dotfiles directory"; exit 1; }

if yes_or_no "Would you like to install packages?" "y"; then
  mapfile -t installed < <(multiselect "./packages/pkg-list-pacman.txt")
  sudo pacman -Sy --needed --noconfirm "${installed[@]}"
fi

if yes_or_no "Would you like to install AUR packages?" "y"; then
  mapfile -t selected < <(multiselect "./packages/pkg-list-aur.txt")
  to_install=()
  for pkg in "${selected[@]}"; do
    if ! pacman -Qq "$pkg" &>/dev/null; then
      to_install+=("$pkg")
    fi
  done
  if [[ ${#to_install[@]} -gt 0 ]]; then
    paru -S --needed --noconfirm "${to_install[@]}"
  else
    echo "All selected AUR packages are already installed."
  fi
fi

symlinks=("atuin" "git" "nvim" "prompt" "tms" "tmux" "zsh" "discord" "themes" "ghostty" "zed" "cava" "pipewire" "applications" "environment" "godot" "fastfetch")
if yes_or_no "Would you like to install symbolic links?" "y"; then
  mapfile -t to_link < <(multiselect "${symlinks[@]}")
  for item in "${to_link[@]}"
  do
    echo "Linking $item..."
    if stow -n -v -d "$DOTFILES_DIR" -t "$HOME" "$item"; then
      stow -v -d "$DOTFILES_DIR" -t "$HOME" "$item"
    else
      echo "Conflicts in $item. Use --adopt? (backs up your files to repo)"
      if yes_or_no "Adopt existing files for $item?"; then
        stow --adopt=* -v -d "$DOTFILES_DIR" -t "$HOME" "$item"
      else
        echo "Skipping $item"
      fi
    fi
  done
fi

system_links=("pacman" "grub")
if yes_or_no "Would you like to install system links?" "y"; then
  mapfile -t to_link < <(multiselect "${system_links[@]}")
  for item in "${to_link[@]}"
  do
    echo "Installing $item configuration..."
    if sudo stow -n -v -d "$DOTFILES_DIR" -t "/" "$item"; then
      sudo stow -v -d "$DOTFILES_DIR" -t "/" "$item"
    else
      echo "Conflicts in $item. Use --adopt? (backs up your files to repo)"
      if yes_or_no "Adopt existing files for $item?"; then
        sudo stow --adopt=* -v -d "$DOTFILES_DIR" -t "/" "$item"
      else
        echo "Skipping $item"
      fi
    fi
  done
fi

if yes_or_no "Would you like to enable magic SYSRQ?" "y"; then
  echo "Enabling magic SYSRQ..."
  echo "kernel.sysrq = 1" | sudo tee /etc/sysctl.d/99-sysrq.conf > /dev/null
  sudo sysctl --system > /dev/null
  echo "Magic SYSRQ enabled permanently."
fi

echo "Installation complete!"
if yes_or_no "A reboot is advised for changes to take effect. Proceed with reboot?"; then
  sudo reboot
else
  echo "That's fine by me. Have a nice day!"
fi
