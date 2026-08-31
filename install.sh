#!/usr/bin/env bash

trap "echo -e '\nCanceling installation...'; exit 130" INT

if [[ ${BASH_VERSINFO[0]} -lt 4 ]] || [[ ${BASH_VERSINFO[0]} -eq 4 && ${BASH_VERSINFO[1]} -lt 3 ]]; then
  echo "Error: This script requires Bash 4.3 or higher"
  echo "Current version: $BASH_VERSION"
  exit 1
fi

TEMP_DIRS=()

cleanup_temps() {
  local dir
  for dir in "${TEMP_DIRS[@]}"; do
    rm -rf "$dir"
  done
}

trap cleanup_temps EXIT


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

echo "Installing necessary packages..."
sudo pacman -S --needed --noconfirm git base-devel

if ! command -v paru &> /dev/null; then
  echo "Installing paru..."
  paru_dir="$(mktemp -d)"
  TEMP_DIRS+=("$paru_dir")
  git clone https://aur.archlinux.org/paru.git "$paru_dir" || { echo "Failed to clone paru directory"; exit 1; }
  cd "$paru_dir" || { echo "Failed to enter paru directory"; exit 1; }
  makepkg -si --noconfirm || { echo "Failed to install paru"; exit 1; }
  cd "$HOME" ||  { echo "Failed to enter home directory"; exit 1; }
fi

cd "$DOTFILES_DIR" || { echo "Failed to enter dotfiles directory"; exit 1; }

if yes_or_no "Would you like to enable all symbolic links" "y"; then
  stow . || { echo "Symbolic links failed to be enabled!"; exit 1; }
fi

if yes_or_no "Would you like to enable magic SYSRQ?" "y"; then
  echo "Enabling magic SYSRQ..."
  echo "kernel.sysrq = 1" | sudo tee /etc/sysctl.d/99-sysrq.conf > /dev/null
  sudo sysctl --system > /dev/null
  echo "Magic SYSRQ enabled permanently."
fi

echo "Installation complete!"
if yes_or_no "A reboot is advised for changes to take effect. Proceed with reboot?" "y"; then
  sudo reboot
else
  echo "That's fine by me. Have a nice day!"
fi
