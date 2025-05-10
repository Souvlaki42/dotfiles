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

1. On Windows, run `setup.ps1` as administrator:

```powershell
Invoke-RestMethod -Uri https://raw.githubusercontent.com/Souvlaki42/dotfiles/refs/heads/main/setup.ps1 | Invoke-Expression
```

2. On Linux, run `setup.sh`:

```bash
curl -sSL https://raw.githubusercontent.com/Souvlaki42/dotfiles/refs/heads/main/setup.sh | bash -i
```

## Todo

- [ ] Add support for installing packages.
- [ ] Add neovim configuration.
- [ ] Add support for removing broken or stale symlinks. (WIP)

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.
