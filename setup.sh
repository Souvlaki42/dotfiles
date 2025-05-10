#!/bin/bash

# Checks if python3 or python is installed
$PYTHON = "python3"
if ! command -v python3 &> /dev/null; then
    if ! command -v python &> /dev/null; then
        echo "Error: Python not found. Please install Python 3.x."
        echo "For Debian/Ubuntu, you can run 'sudo apt install python3'."
        echo "For Arch Linux, you can run 'sudo pacman -S python'."
        echo "For other distributions, please refer to your package manager's documentation."
        exit 1
    else
        $PYTHON = "python"
    fi
fi

# Checks if git is installed
if ! command -v git &> /dev/null; then
    echo "Error: Git not found. Please install Git."
    echo "For Debian/Ubuntu, you can run 'sudo apt install git'."
    echo "For Arch Linux, you can run 'sudo pacman -S git'."
    echo "For other distributions, please refer to your package manager's documentation."
    exit 1
fi

# Clones the repository if it doesn't exist
if [ ! -d "$HOME/dotfiles" ]; then
    echo "Cloning dotfiles repository..."
    git clone --depth 1 https://github.com/Souvlaki42/dotfiles.git "$HOME/dotfiles" || echo "Error: Failed to clone dotfiles repository. Please try again." && exit 1
    cd "$HOME/dotfiles"
else
    echo "Updating dotfiles repository..."
    cd "$HOME/dotfiles"
    git pull
fi

# Installs the dotfiles
echo "Installing dotfiles..."
$PYTHON manager/main.py