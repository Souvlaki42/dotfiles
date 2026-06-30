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

function multiselect() {
  local -n selected_array=$1
  local input=("${@:2}")
  local options=()

  # Allow passing either a file to read from or a list of options
  if [[ -f "${input[0]}" && ${#input[@]} -eq 1 ]]; then
    mapfile -t options < "${input[0]}"
  else
    options=("${input[@]}")
  fi

  local selected exit_code
  selected=$(printf "%s\n" "${options[@]}" | fzf --multi --layout=reverse --bind "ctrl-a:select-all,ctrl-d:deselect-all")
  exit_code=$?

  if [[ $exit_code -eq 130 ]]; then
    return 130
  elif [[ $exit_code -ne 0 ]]; then
    echo "Error: FZF exited with code $exit_code" >&2
    return 1
  fi

  if [[ -z "$selected" ]]; then
    echo "No options selected." >&2
    return 1
  fi

  # shellcheck disable=SC2034
  mapfile -t selected_array <<< "$selected"
  return 0
}

function multiselect_or_skip() {
  # shellcheck disable=SC2034
  local -n result_ref=$1
  shift
  
  if multiselect result_ref "$@"; then
    return 0
  else
    local exit_code=$?
    if [[ $exit_code -eq 130 ]]; then
      echo "Selection cancelled, skipping..." >&2
      return 130
    else
      echo "Error during selection" >&2
      exit $exit_code
    fi
  fi
}

echo "Installing necessary packages..."
sudo pacman -S --needed --noconfirm fzf git base-devel

if ! command -v fzf &> /dev/null; then
  echo "Fzf not found. Please install it."
  exit 1
fi

if ! command -v stow &> /dev/null; then
  echo "Stow not found. Please install it."
  exit 1
fi

if ! command -v git &> /dev/null; then
  echo "Git not found. Please install it."
  exit 1
fi

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

  if yes_or_no "Would you like to install packages?" "y"; then
    installed=()
    if multiselect_or_skip installed "./packages/pkg-list-pacman.txt"; then
      sudo pacman -S --needed --noconfirm "${installed[@]}"
    fi
  fi

  if yes_or_no "Would you like to install AUR packages?" "y"; then
    selected=()
    to_install=()
    if multiselect_or_skip selected "./packages/pkg-list-aur.txt"; then
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
  fi

symlinks=("atuin" "git" "nvim" "prompt" "sesh" "tmux" "zsh" "discord" "themes" "ghostty" "zed" "cava" "pipewire" "applications" "environment" "fastfetch" "pnpm")
if yes_or_no "Would you like to install symbolic links?" "y"; then
  to_link=()
  if multiselect_or_skip to_link "${symlinks[@]}"; then
    for item in "${to_link[@]}"
    do
      echo "Linking $item..."
      if stow -n -v -d "$DOTFILES_DIR" -t "$HOME" "$item" &>/dev/null; then
        stow -v -d "$DOTFILES_DIR" -t "$HOME" "$item"
      else
        echo "Conflicts in $item. Use --adopt? (backs up your files to repo)"
        if yes_or_no "Adopt existing files for $item?" "y"; then
          stow --adopt -v -d "$DOTFILES_DIR" -t "$HOME" "$item"
        else
          echo "Skipping $item"
        fi
      fi
    done
  fi
fi

if yes_or_no "Would you like to enable the gcr-ssh-agent service?" "y"; then
  systemctl --user daemon-reload
  systemctl --user enable --now gcr-ssh-agent.socket
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
