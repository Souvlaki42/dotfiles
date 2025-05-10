# Dotfiles

My configuration for Arch Linux based installations using Hyprland (can dual boot with Windows 11).

![Arch Linux Logo](https://upload.wikimedia.org/wikipedia/commons/f/f9/Archlinux-logo-standard-version.svg)

## Uses

OS -> Arch Linux \
Window Manager -> Hyprland \
Display Manager -> SDDM (Theme: Chili) \
Theme -> Catppuccin Mocha \
Dotfiles Manager -> GNU Stow \
Fetch -> Fastfetch \
Prompt -> Oh My Posh (RIP p10k) \
Cursor -> Bibata Modern Ice \
Font -> JetBrains Mono Nerd Font \
Terminal -> Kitty \
Filemanager -> Thunar \
Browser -> Firefox \
Launcher -> Wofi \
Bar -> Waybar \
Logout -> Wlogout \
Chat -> WebCord \
Music -> Spotify \
Editor -> VS Code \
Notes -> Dynalist \
Game Engine -> Godot/Mono \
Screenshot Engine -> Grim

## How to use

1. Connect to internet.
   Ethernet should work automatically.
   For WiFi, run these:

```bash
# First, open the WiFi connection utility tool:
iwctl
# If you do not know your wireless device name, list all Wi-Fi devices:
device list
# Then, to initiate a scan for networks (note that this command will not output anything):
station <device> scan
# You can then list all available networks:
station <device> get-networks
# Finally, to connect to a network:
station <device> connect <SSID>
# You may get prompted to type the network's passphrase
# To make sure that the connection was initialized correctly:
station <device> show
# Quit the tool and move to the next step.
# For more documentation related to WiFi: https://wiki.archlinux.org/title/iwd.
```

2. Partition your drive.
   You can choose automatic, but this is how to do it manually:

```bash
# First, list disks:
fdisk -l
# Then, open partition manager tool to the disk you plan to install Arch Linux to:
cfdisk /dev/<disk_name>
# Delete any previous partitions you don't need now.
# You need to manually create:
# - An 1G EFI system partition out of free space.
# - A <ram_size>G Linux swap partition out of free space (optional).
# - A Linux filesystem partition with the remaining free space.
# Write the changes you just did and exit the partitioning tool.
# Next, format the partitions you just created:
mkfs.fat -F32 /dev/<efi_partition> # Format efi_partition as fat32.
mkfs.(ext4 or btrfs) /dev/<filesystem_partition> # Format filesystem_partition as ext4 or btrfs.
mkswap /dev/<swap_partition> # Register the swap_partition.
swapon /dev/<swap_partition> # Enable the swap_partition.
# Finally, mount the efi and filesystem partitions (and optionally the windows one):
mount /dev/<filesystem_partition> /mnt # Mount filesystem_partition to /mnt.
mount /dev/<efi_partition> /mnt/boot # Mount efi_partition to /mnt/boot.
mount /dev/<windows_partition> /mnt/windows # Mount windows_partition to /mnt/windows.
```

3. Run the archinstall script:

```bash
# Manual configuration
archinstall
# DON'T FORGET, to set up a user account.
# OPTIONALY, you can set up a root password as well.
# OPTIONALY, you can save your configuration to /mnt/root or somewhere else)
# When you are done configuring, press install, wait to be done, say no to chroot, reboot and move to the next and final step.
```

