import os
import sys
import platform
import shutil  # For rmtree
from typing import TypedDict, Dict  # Use Dict for type hints

# Define a type for the configuration dictionary for better type hinting
Configuration = TypedDict(
    "Configuration",
    {
        "dotfiles_dir": str,
        "common_mappings": Dict[str, str],
        "linux_mappings": Dict[str, str],
        "windows_mappings": Dict[str, str],
        "hyprland_mappings": Dict[str, str],
    },
)

DEFAULT_OPTIONS: Configuration = {
    "dotfiles_dir": os.path.expanduser("~/dotfiles"),
    "common_mappings": {
        "common/.gitconfig": ".gitconfig",
        "common/shell.toml": ".shell.toml",
    },
    "linux_mappings": {
        "linux/.zshrc": ".zshrc",
        "linux/.tmux.conf": ".tmux.conf",
    },
    "windows_mappings": {
        "windows/powershell/Microsoft.PowerShell_profile.ps1": "Documents/PowerShell/Microsoft.PowerShell_profile.ps1",
    },
    "hyprland_mappings": {
        "hyprland/.gtkrc-2.0": ".gtkrc-2.0",
        "hyprland/.config/gtk-3.0": ".config/gtk-3.0",
        "hyprland/.config/hypr": ".config/hypr",
        "hyprland/.config/kitty": ".config/kitty",
        "hyprland/.config/swaync": ".config/swaync",
        "hyprland/.config/waybar": ".config/waybar",
        "hyprland/.config/wlogout": ".config/wlogout",
    },
}


def yes_or_no(question: str) -> bool:
  """
  Asks the user a yes/no question and returns True if the answer is yes.
  Loops until a valid 'y' or 'n' is given. Defaults to 'N' on empty input.
  """
  while True:
    answer: str = input(f"{question} [y/N]: ").lower().strip()
    if answer == "y":
      return True
    elif answer == "n" or answer == "":  # Default to No if empty
      return False
    else:
      print("Invalid input. Please enter 'y' or 'n'.")


def symlink_dotfile(
    source_name_in_repo: str, target_name_in_home: str, dotfiles_repo_dir: str
) -> None:
  """
  Creates a symbolic link from the dotfiles repository to the home directory.
  Handles files and directories, with prompts for overwriting.

  Args:
      source_name_in_repo (str): Path to the source file/directory
                                 relative to dotfiles_repo_dir.
      target_name_in_home (str): Path to the target file/directory
                                 relative to the user's home directory.
                                 Should NOT start with a '/'.
      dotfiles_repo_dir (str): Absolute path to the root of the dotfiles repository.
  """
  source_path = os.path.join(dotfiles_repo_dir, source_name_in_repo)
  target_path = os.path.expanduser(os.path.join("~", target_name_in_home))

  print(f"\nProcessing: '{source_name_in_repo}' -> '~/{target_name_in_home}'")

  if not os.path.exists(source_path):
    print(f"  SKIPPING: Source path does not exist: {source_path}")
    return

  # Ensure parent directory of the target exists
  target_parent_dir = os.path.dirname(target_path)
  if not os.path.exists(target_parent_dir):
    print(f"  Creating parent directory for target: {target_parent_dir}")
    try:
      os.makedirs(target_parent_dir, exist_ok=True)
    except OSError as e:
      print(f"  ERROR: Could not create parent directory {target_parent_dir}: {e}")
      return

  # Handle existing target at the exact target_path
  if os.path.lexists(target_path):  # lexists checks symlinks themselves
    removed_existing = False
    if os.path.islink(target_path):
      if yes_or_no(f"  Target '{target_path}' is an existing symlink. Remove it?"):
        try:
          os.unlink(target_path)
          print(f"  Removed existing symlink: {target_path}")
          removed_existing = True
        except OSError as e:
          print(f"  ERROR: Could not remove symlink {target_path}: {e}")
          return  # Stop processing this item if removal failed
      else:
        print(f"  Skipping link creation for '{target_path}' as existing symlink was not removed.")
        return
    elif os.path.isdir(target_path):
      print(f"  WARNING: Target '{target_path}' is an existing directory.")
      if yes_or_no(
          f"  Delete the entire directory '{target_path}' and ALL its contents?"
      ):
        try:
          shutil.rmtree(target_path)
          print(f"  Removed existing directory: {target_path}")
          removed_existing = True
        except OSError as e:
          print(f"  ERROR: Could not remove directory {target_path}: {e}")
          return
      else:
        print(f"  Skipping link creation for '{target_path}' as existing directory was not removed.")
        return
    elif os.path.isfile(target_path):
      if yes_or_no(f"  Target '{target_path}' is an existing file. Remove it?"):
        try:
          os.remove(target_path)
          print(f"  Removed existing file: {target_path}")
          removed_existing = True
        except OSError as e:
          print(f"  ERROR: Could not remove file {target_path}: {e}")
          return
      else:
        print(f"  Skipping link creation for '{target_path}' as existing file was not removed.")
        return
    else:  # Other types like sockets, FIFOs etc.
      if yes_or_no(
          f"  Target '{target_path}' exists and is not a regular file, directory, or symlink. Attempt to remove?"
      ):
        try:
          os.unlink(target_path)
          print(f"  Removed existing special file: {target_path}")
          removed_existing = True
        except OSError as e:
          print(f"  ERROR: Could not remove {target_path}: {e}")
          return
      else:
        print(f"  Skipping link creation for '{target_path}' as existing item was not removed.")
        return

    # If we intended to remove something but it still exists, something went wrong earlier.
    # The returns above should handle this, but as a safeguard:
    if not removed_existing and os.path.lexists(target_path):
      print(f"  Skipping link creation for {target_path} as existing item was not successfully removed.")
      return

  # Create the symlink
  print(f"  Attempting to link: '{source_path}' -> '{target_path}'")
  try:
    is_dir_source = os.path.isdir(source_path)
    os.symlink(source_path, target_path, target_is_directory=is_dir_source)
    print(f"  SUCCESS: Linked '{target_path}'")
  except OSError as e:
    print(f"  ERROR creating symlink for '{target_path}': {e}")
    if platform.system() == "Windows":
      print(
          "  On Windows, creating symlinks might require administrator "
          "privileges or Developer Mode to be enabled."
      )
  except Exception as e:
    print(f"  An unexpected error occurred while linking '{target_path}': {e}")


def install_dotfiles(config: Configuration = DEFAULT_OPTIONS) -> None:
  """Installs dotfiles based on the provided configuration."""
  print(f"Dotfiles repository location: {config['dotfiles_dir']}")
  if not os.path.exists(config["dotfiles_dir"]):
    print(f"\nERROR: Dotfiles directory not found at '{config['dotfiles_dir']}'")
    print("Please clone your dotfiles repository there first, e.g.:")
    print(f"  git clone <your-repo-url> {config['dotfiles_dir']}")
    sys.exit(1)

  print("\n--- Processing Common Dotfiles ---")
  if not config["common_mappings"]:
    print("No common dotfiles specified.")
  else:
    for src, dest in config["common_mappings"].items():
      symlink_dotfile(src, dest, config["dotfiles_dir"])

  current_os = platform.system()
  if current_os == "Linux":
    print("\n--- Processing Linux Specific Dotfiles ---")
    if not config["linux_mappings"]:
      print("No Linux-specific dotfiles specified.")
    else:
      for src, dest in config["linux_mappings"].items():
        symlink_dotfile(src, dest, config["dotfiles_dir"])

    if config["hyprland_mappings"]:
      if yes_or_no("\nDo you want to install Hyprland specific dotfiles?"):
        print("\n--- Processing Hyprland Specific Dotfiles ---")
        for src, dest in config["hyprland_mappings"].items():
          symlink_dotfile(src, dest, config["dotfiles_dir"])
      else:
        print("Skipping Hyprland dotfiles installation.")

  elif current_os == "Windows":
    print("\n--- Processing Windows Specific Dotfiles ---")
    if not config["windows_mappings"]:
      print("No Windows-specific dotfiles specified.")
    else:
      for src, dest in config["windows_mappings"].items():
        symlink_dotfile(src, dest, config["dotfiles_dir"])
  else:
    print(f"\nUnsupported OS: {current_os}. Skipping OS-specific dotfiles.")

  print("\n------------------------------------")
  print("Dotfiles setup script finished.")
  if platform.system() == "Windows":
    print("REMINDER: For symlinks to work correctly on Windows without admin rights,")
    print("Developer Mode should be enabled (Settings -> Privacy & security -> For developers).")
    print("Alternatively, run this script as an Administrator.")


def main() -> None:
  """Main function of the script."""
  print("==========================================")
  print("=== Dotfiles Installer Script ===")
  print("==========================================")
  install_dotfiles(DEFAULT_OPTIONS)  # Uses the global DEFAULT_OPTIONS


if __name__ == "__main__":
  main()
