import os
import sys

DOTFILES_DIR = os.path.expanduser("~/dotfiles")
COMMON_MAPPINGS = {
    "common/.gitconfig": ".gitconfig",
    "common/shell.toml": "shell.toml",
}
LINUX_MAPPINGS = {
    "linux/.zshrc": ".zshrc",
    "linux/.tmux.conf": ".tmux.conf",
}
WINDOWS_MAPPINGS = {
    "windows/profile.ps1": "Documents/PowerShell/Microsoft.PowerShell_profile.ps1",
}
HYPRLAND_MAPPINGS = {
    "hyprland/.gtkrc-2.0": ".gtkrc-2.0",
    "hyprland/.config/gtk-3.0": ".config/gtk-3.0",
    "hyprland/.config/hypr": ".config/hypr",
    "hyprland/.config/kitty": ".config/kitty",
    "hyprland/.config/swaync": ".config/swaync",
    "hyprland/.config/waybar": ".config/waybar",
    "hyprland/.config/wlogout": ".config/wlogout",
}
BROKEN_LINKS_LOOKUP = {
    os.path.expanduser("~/"): False,
    os.path.expanduser("~/.config"): True,
}


def yes_or_no(question: str) -> bool:
  """Asks a yes/no question and returns True if the answer is yes, False otherwise."""
  if not sys.stdin.isatty():  # Check if running interactively
    print(f"Skipping interactive question: {question} (assuming 'no')")
    return False  # Or True, if you want to default to 'yes'

  while True:
    answer: str = input(f"{question} [y/N]: ").lower().strip()
    if answer in ("y", "yes"):
      return True
    elif answer in ("n", "no", ""):
      return False
    else:
      print("Invalid input. Please enter 'y' or 'n'.")
