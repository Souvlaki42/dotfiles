import shutil
import platform
from utils import *


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
