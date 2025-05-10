import sys
from .symlink import *

def install_dotfiles() -> None:
  """Installs dotfiles based on the provided configuration."""
  print(f"Dotfiles repository location: {DOTFILES_DIR}")
  if not os.path.exists(DOTFILES_DIR):
    print(f"\nERROR: Dotfiles directory not found at '{DOTFILES_DIR}'")
    print("Please clone your dotfiles repository there first, e.g.:")
    print(f"  git clone <your-repo-url> {DOTFILES_DIR}")
    sys.exit(1)

  print("\n--- Processing Common Dotfiles ---")
  if not COMMON_MAPPINGS:
    print("No common dotfiles specified.")
  else:
    for src, dest in COMMON_MAPPINGS.items():
      symlink_dotfile(src, dest, DOTFILES_DIR)

  current_os = platform.system()
  if current_os == "Linux":
    print("\n--- Processing Linux Specific Dotfiles ---")
    if not LINUX_MAPPINGS:
      print("No Linux-specific dotfiles specified.")
    else:
      for src, dest in LINUX_MAPPINGS.items():
        symlink_dotfile(src, dest, DOTFILES_DIR)

    if HYPRLAND_MAPPINGS:
      if yes_or_no("\nDo you want to install Hyprland specific dotfiles?"):
        print("\n--- Processing Hyprland Specific Dotfiles ---")
        for src, dest in HYPRLAND_MAPPINGS.items():
          symlink_dotfile(src, dest, DOTFILES_DIR)
      else:
        print("Skipping Hyprland dotfiles installation.")

  elif current_os == "Windows":
    print("\n--- Processing Windows Specific Dotfiles ---")
    if not WINDOWS_MAPPINGS:
      print("No Windows-specific dotfiles specified.")
    else:
      for src, dest in WINDOWS_MAPPINGS.items():
        symlink_dotfile(src, dest, DOTFILES_DIR)
  else:
    print(f"\nUnsupported OS: {current_os}. Skipping OS-specific dotfiles.")

  print("\n------------------------------------")
  print("Dotfiles setup script finished.")
  if platform.system() == "Windows":
    print("REMINDER: For symlinks to work correctly on Windows without admin rights,")
    print("Developer Mode should be enabled (Settings -> Privacy & security -> For developers).")
    print("Alternatively, run this script as an Administrator.")