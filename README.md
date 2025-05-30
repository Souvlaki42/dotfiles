# Dotfiles

My configurations for every OS I have ever used as a daily driver aka Windows + WSL2 (Ubuntu) and Arch Linux.

> [!IMPORTANT]
> If you like this repo consider giving it a ⭐. Thank you for your time. \
> If you find any bugs, please open an issue. \
> If you have any suggestions, please open a PR. \
> If you want to support me, consider sponsoring me on GitHub.

![Arch Linux Logo](https://upload.wikimedia.org/wikipedia/commons/f/f9/Archlinux-logo-standard-version.svg)

![Windows 11 Logo](https://upload.wikimedia.org/wikipedia/commons/e/e6/Windows_11_logo.svg)

![Ubuntu Logo](https://upload.wikimedia.org/wikipedia/commons/9/9d/Ubuntu_logo.svg)

## Features

- Installs dotfiles for Windows.
- Installs dotfiles for Linux (Hyprland and WSL2).
- Handles symlinking of dotfiles.
- Handles updating of dotfiles.
- Handles existing files in the target location.
- Handles installing packages. (soon)
- Handles removing broken or stale symlinks. (soon)

## How to use

1. Make sure you have [Python 3.x](https://www.python.org/downloads/) installed on your system.
2. Make sure you have [Git](https://git-scm.com/download/win) installed on your system.
3. If you are on Windows, make sure you have the latest version of [Powershell](https://github.com/PowerShell/PowerShell/releases) installed and then run the following commands:

```powershell
Install-Module syntax-highlighting -Scope CurrentUser
```

```powershell
Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser
```

4. Clone this repository to your home directory:

```bash
git clone --depth 1 https://github.com/Souvlaki42/dotfiles.git $HOME/dotfiles # You can clone it anywhere you want.
```

5. Run the setup script:

```bash
cd $HOME/dotfiles # Navigate to the dotfiles directory
python setup.py # If this doesn't work, try python3 setup.py
```

## Todo

- [ ] Add support for installing packages.
- [ ] Add neovim configuration.
- [ ] Add support for removing broken or stale symlinks. (WIP)

## Unlicense

This project is released into the public domain. See the [UNLICENSE](UNLICENSE) file for details.

