# Dotfiles

My configuration for Windows 11 based installations

![Windows 11 Logo](https://upload.wikimedia.org/wikipedia/commons/e/e6/Windows_11_logo.svg)

## Uses

**OS** -> Windows 11 24H2 Home Edition \
**Fetch** -> Fastfetch \
**Prompt** -> Oh My Posh (RIP p10k) \
**Cursor** -> Bibata Modern Ice \
**Font** -> Hack Nerd Font \
**Terminal** -> Windows Terminal \
**Filemanager** -> Windows Explorer \
**Chat** -> VenCord \
**Music** -> Youtube \
**Editor** -> VS Code/Neovim \
**Notes** -> Obsidian \
**Game Engine** -> Godot \
**Package Manager** -> Scoop \

## How to use

1. Install [Python](https://www.python.org/)

2. Install the required powershell modules:

- [Syntax Highlighting](https://github.com/digitalguy99/pwsh-syntax-highlighting)

```pwsh
Install-Module -Name syntax-highlighting
```

- [Terminal icons](https://github.com/devblackops/Terminal-Icons)

```pwsh
Install-Module -Name Terminal-Icons -Repository PSGallery
```

3. Clone this repo using:

```pwsh
git clone https://github.com/Souvlaki42/dotfiles.git --depth 1 ~/dotfiles
```

4. Install the required dotfiles:

```pwsh
# Make sure you are running powershell as an Administrator
python ~/dotfiles/setup.py
```

