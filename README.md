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

## How to use

1. Install [Python](https://www.python.org/). It's already there on Linux systems.

2. For Windows, follow the instructions in the [windows](windows) directory.

3. Follow the instructions in the [hyprland](hyprland) directory if you want help installing Hyprland.

4. For Linux, it's should be as easy as running the following commands:

```bash
git clone https://github.com/Souvlaki42/dotfiles.git --depth 1 ~/dotfiles
python ~/dotfiles/setup.py
```

## How to update

1. Run the following commands to update the dotfiles repository:

```bash
cd ~/dotfiles
git pull
```

2. Run the following commands to update the dotfiles:

```bash
python ~/dotfiles/setup.py
```

## Todo

- [ ] Add support for installing packages.
- [ ] Add neovim configuration.

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.

