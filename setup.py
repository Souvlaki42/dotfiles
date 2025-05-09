import os
import sys
import platform
import shutil
from typing import TypedDict, Dict, List, Set # Make sure these are imported

Configuration = TypedDict("Configuration", {
  "dotfiles_dir": str,
  "common_mappings": Dict[str, str],
  "linux_mappings": Dict[str, str],
  "windows_mappings": Dict[str, str],
  "hyprland_mappings": Dict[str, str],
})

DEFAULT_OPTIONS: Configuration = {
    "dotfiles_dir": os.path.expanduser("~/dotfiles"),
    "common_mappings": {
        "common/.gitconfig": ".gitconfig",
        "common/shell.toml": "shell.toml",
    },
    "linux_mappings": {
        "linux/.zshrc": ".zshrc",
        "linux/.tmux.conf": ".tmux.conf",
    },
    "windows_mappings": {
        "windows/profile.ps1": "Documents/PowerShell/Microsoft.PowerShell_profile.ps1",
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
    while True:
        answer: str = input(f"{question} [y/N]: ").lower().strip()
        if answer == "y":
            return True
        elif answer == "n" or answer == "":
            return False
        else:
            print("Invalid input. Please enter 'y' or 'n'.")

def symlink_dotfile(source_name, target_name_in_home, dotfiles_dir: str) -> None:
    source_path = os.path.join(dotfiles_dir, source_name)
    target_path = os.path.expanduser(os.path.join("~", target_name_in_home))

    if not os.path.exists(source_path):
        print(f"  SKIPPING: Source path does not exist: {source_path}")
        return

    target_parent_dir = os.path.dirname(target_path)
    if not os.path.exists(target_parent_dir):
        print(f"  Creating parent directory for target: {target_parent_dir}")
        try:
            os.makedirs(target_parent_dir, exist_ok=True)
        except OSError as e:
            print(f"  ERROR: Could not create parent directory {target_parent_dir}: {e}")
            return
    if os.path.lexists(target_path):
        removed_existing = False
        if os.path.islink(target_path):
            if yes_or_no(f"  Target '{target_path}' is an existing symlink. Remove it?"):
                try:
                    os.unlink(target_path)
                    print(f"  Removed existing symlink: {target_path}")
                    removed_existing = True
                except OSError as e:
                    print(f"  ERROR: Could not remove symlink {target_path}: {e}")
                    return
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
        else:
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
        if not removed_existing and os.path.lexists(target_path):
             print(f"  Skipping link creation for {target_path} as existing item was not removed.")
             return
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


def _get_all_managed_target_abs_paths(config: Configuration) -> Set[str]:
    managed_target_paths: Set[str] = set()
    all_mapping_groups = [
        config.get("common_mappings", {}),
        config.get("linux_mappings", {}),
        config.get("windows_mappings", {}),
        config.get("hyprland_mappings", {}),
    ]
    for mapping_group in all_mapping_groups:
        if mapping_group:
            for target_name_in_home in mapping_group.values():
                full_target_path = os.path.abspath(
                    os.path.expanduser(os.path.join("~", target_name_in_home))
                )
                managed_target_paths.add(os.path.normpath(full_target_path))
    return managed_target_paths

def _prompt_and_remove_links(
    links_to_process: List[str],
    link_type_name: str,
    reason_message: str,
    prompt_for_each_removal: bool
) -> None:
    print(f"\n  Found {len(links_to_process)} potential {link_type_name} symlink(s) {reason_message}:")
    for link_path in links_to_process:
        try:
            link_target_display = os.readlink(link_path)
            print(f"    - '{link_path}'  ->  '{link_target_display}'")
        except OSError:
            print(f"    - '{link_path}'  ->  [Error reading target]")

    removed_count = 0
    if not links_to_process:
        return

    if prompt_for_each_removal:
        if not yes_or_no(f"\n  Do you want to review and remove these {link_type_name} symlinks individually?"):
            print(f"  {link_type_name.capitalize()} symlink removal aborted by user.")
            return
        
        for link_path in links_to_process:
            link_target_display = "[Could not re-read target]"
            try:
                link_target_display = os.readlink(link_path)
            except OSError: pass

            if yes_or_no(f"    Remove {link_type_name} symlink '{link_path}' (points to '{link_target_display}')?"):
                try:
                    os.unlink(link_path)
                    print(f"      Removed: '{link_path}'")
                    removed_count += 1
                except OSError as e:
                    print(f"      ERROR: Could not remove '{link_path}': {e}")
    else:
        if yes_or_no(f"\n  WARNING: About to remove all {len(links_to_process)} "
                       f"listed {link_type_name} symlinks without individual prompts. Proceed?"):
            for link_path in links_to_process:
                try:
                    os.unlink(link_path)
                    print(f"    Removed: '{link_path}'")
                    removed_count += 1
                except OSError as e:
                    print(f"    ERROR: Could not remove '{link_path}': {e}")
        else:
            print(f"  {link_type_name.capitalize()} symlink removal aborted by user.")

    if removed_count > 0:
        print(f"\n  Successfully removed {removed_count} {link_type_name} symlink(s).")
    elif links_to_process:
        print(f"\n  No {link_type_name} symlinks were removed by user choice or due to errors.")


def remove_stale_symlinks(
    config: Configuration,
    prompt_before_scan: bool = True,
    prompt_for_each_removal: bool = True,
) -> None:
    if prompt_before_scan:
        if not yes_or_no(
            "\nDo you want to scan for and remove STALE symlinks?\n"
            "(Stale = points to your dotfiles repo, but its location "
            "is NOT in your current script mappings)"
        ):
            print("Skipping stale symlink check.")
            return
    print("\n--- Checking for STALE Symlinks ---")
    abs_dotfiles_dir = os.path.abspath(os.path.expanduser(config["dotfiles_dir"]))
    if not os.path.isdir(abs_dotfiles_dir):
        print(f"  Dotfiles directory '{config['dotfiles_dir']}' ({abs_dotfiles_dir}) "
              "does not exist. Cannot check for stale links. Skipping.")
        return
    managed_target_abs_paths = _get_all_managed_target_abs_paths(config)
    stale_links_found: List[str] = []
    home_dir = os.path.expanduser("~")
    home_config_dir = os.path.join(home_dir, ".config")
    print(f"  Scanning direct children of: {home_dir}")
    try:
        for item_name in os.listdir(home_dir):
            item_path = os.path.join(home_dir, item_name)
            if os.path.islink(item_path):
                try:
                    link_target_str = os.readlink(item_path)
                    abs_link_target = os.path.normpath(os.path.abspath(
                        os.path.join(os.path.dirname(item_path), link_target_str)
                    ))
                    norm_item_path = os.path.normpath(item_path)
                    is_pointing_to_dotfiles = abs_link_target.startswith(
                        abs_dotfiles_dir + os.sep
                    ) or abs_link_target == abs_dotfiles_dir
                    is_unmanaged = norm_item_path not in managed_target_abs_paths
                    if is_pointing_to_dotfiles and is_unmanaged:
                        stale_links_found.append(norm_item_path)
                except OSError: pass
    except OSError as e: print(f"  Warning: Could not list HOME directory '{home_dir}': {e}")
    if os.path.isdir(home_config_dir):
        print(f"  Recursively scanning: {home_config_dir}")
        for root, _, files_and_dirs in os.walk(home_config_dir, topdown=True, followlinks=False):
            for name in files_and_dirs:
                item_path = os.path.join(root, name)
                if os.path.islink(item_path):
                    try:
                        link_target_str = os.readlink(item_path)
                        abs_link_target = os.path.normpath(os.path.abspath(
                            os.path.join(os.path.dirname(item_path), link_target_str)
                        ))
                        norm_item_path = os.path.normpath(item_path)
                        is_pointing_to_dotfiles = abs_link_target.startswith(
                            abs_dotfiles_dir + os.sep
                        ) or abs_link_target == abs_dotfiles_dir
                        is_unmanaged = norm_item_path not in managed_target_abs_paths
                        if is_pointing_to_dotfiles and is_unmanaged:
                            if norm_item_path not in stale_links_found:
                                stale_links_found.append(norm_item_path)
                    except OSError: pass
    else: print(f"  Directory '{home_config_dir}' does not exist. Skipping its scan.")
    if not stale_links_found:
        print("  No stale symlinks found.")
        return
    _prompt_and_remove_links(
        stale_links_found, "stale",
        f"pointing to '{abs_dotfiles_dir}' and not in current mappings",
        prompt_for_each_removal
    )

def remove_misplaced_dotfile_symlinks(
    config: Configuration,
    prompt_before_scan: bool = True,
    prompt_for_each_removal: bool = True,
) -> None:
    if prompt_before_scan:
        if not yes_or_no(
            "\nDo you want to scan for and remove MISPLACED symlinks?\n"
            "(Misplaced = points to your dotfiles repo, but the link itself "
            "is in an unexpected location not defined as a target in your script)"
        ):
            print("Skipping misplaced symlink check.")
            return
    print("\n--- Checking for MISPLACED Dotfile-Pointing Symlinks ---")
    abs_dotfiles_dir = os.path.abspath(os.path.expanduser(config["dotfiles_dir"]))
    if not os.path.isdir(abs_dotfiles_dir):
        print(f"  Dotfiles directory '{config['dotfiles_dir']}' ({abs_dotfiles_dir}) "
              "does not exist. Cannot check for misplaced links. Skipping.")
        return
    managed_target_abs_paths = _get_all_managed_target_abs_paths(config)
    misplaced_links_found: List[str] = []
    home_dir = os.path.expanduser("~")
    home_config_dir = os.path.join(home_dir, ".config")
    print(f"  Scanning direct children of: {home_dir} for any links to dotfiles")
    try:
        for item_name in os.listdir(home_dir):
            item_path = os.path.join(home_dir, item_name)
            if os.path.islink(item_path):
                try:
                    link_target_str = os.readlink(item_path)
                    abs_link_target = os.path.normpath(os.path.abspath(
                        os.path.join(os.path.dirname(item_path), link_target_str)
                    ))
                    norm_item_path = os.path.normpath(item_path)
                    is_pointing_to_dotfiles = abs_link_target.startswith(
                        abs_dotfiles_dir + os.sep
                    ) or abs_link_target == abs_dotfiles_dir
                    is_misplaced = norm_item_path not in managed_target_abs_paths
                    if is_pointing_to_dotfiles and is_misplaced:
                        misplaced_links_found.append(norm_item_path)
                except OSError: pass
    except OSError as e: print(f"  Warning: Could not list HOME directory '{home_dir}': {e}")
    if os.path.isdir(home_config_dir):
        print(f"  Recursively scanning: {home_config_dir} for any links to dotfiles")
        for root, _, files_and_dirs in os.walk(home_config_dir, topdown=True, followlinks=False):
            for name in files_and_dirs:
                item_path = os.path.join(root, name)
                if os.path.islink(item_path):
                    try:
                        link_target_str = os.readlink(item_path)
                        abs_link_target = os.path.normpath(os.path.abspath(
                            os.path.join(os.path.dirname(item_path), link_target_str)
                        ))
                        norm_item_path = os.path.normpath(item_path)
                        is_pointing_to_dotfiles = abs_link_target.startswith(
                            abs_dotfiles_dir + os.sep
                        ) or abs_link_target == abs_dotfiles_dir
                        is_misplaced = norm_item_path not in managed_target_abs_paths
                        if is_pointing_to_dotfiles and is_misplaced:
                            if norm_item_path not in misplaced_links_found:
                                misplaced_links_found.append(norm_item_path)
                    except OSError: pass
    else: print(f"  Directory '{home_config_dir}' does not exist. Skipping its scan.")
    if not misplaced_links_found:
        print("  No misplaced symlinks found pointing to your dotfiles directory.")
        return
    _prompt_and_remove_links(
        misplaced_links_found, "misplaced",
        f"pointing to '{abs_dotfiles_dir}' but located in unconfigured target paths",
        prompt_for_each_removal
    )

# --- Your Main Installation Logic ---
def install_dotfiles(config: Configuration = DEFAULT_OPTIONS) -> None:
    print(f"Dotfiles repository location: {config['dotfiles_dir']}")
    if not os.path.exists(config["dotfiles_dir"]):
        print(f"\nERROR: Dotfiles directory not found at '{config['dotfiles_dir']}'")
        print("Please clone your dotfiles repository there first, e.g.:")
        print(f"  git clone <your-repo-url> \"{config['dotfiles_dir']}\"")
        sys.exit(1)

    print("\n--- Processing Common Dotfiles ---")
    if not config["common_mappings"]:
        print("No common dotfiles specified.")
    else:
        for src, dest in config["common_mappings"].items():
            symlink_dotfile(src, dest, config["dotfiles_dir"]) # Pass config

    current_os = platform.system()
    if current_os == "Linux":
        print("\n--- Processing Linux Specific Dotfiles ---")
        if not config["linux_mappings"]:
            print("No Linux-specific dotfiles specified.")
        else:
            for src, dest in config["linux_mappings"].items():
                symlink_dotfile(src, dest, config["dotfiles_dir"]) # Pass config

        if config["hyprland_mappings"]:
            if yes_or_no("\nDo you want to install Hyprland specific dotfiles?"):
                print("\n--- Processing Hyprland Specific Dotfiles ---")
                for src, dest in config["hyprland_mappings"].items():
                    symlink_dotfile(src, dest, config["dotfiles_dir"]) # Pass config
            else:
                print("Skipping Hyprland dotfiles installation.")

    elif current_os == "Windows":
        print("\n--- Processing Windows Specific Dotfiles ---")
        if not config["windows_mappings"]:
            print("No Windows-specific dotfiles specified.")
        else:
            for src, dest in config["windows_mappings"].items():
                symlink_dotfile(src, dest, config["dotfiles_dir"]) # Pass config
    else:
        print(f"\nUnsupported OS: {current_os}. Skipping OS-specific dotfiles.")


# --- Main Execution ---
def main() -> None:
    """Main function of the script."""
    print("==========================================")
    print("=== Dotfiles Installer Script ===")
    print("==========================================")

    # 1. Perform the primary dotfile installation/linking
    install_dotfiles(DEFAULT_OPTIONS)

    # 2. <<<--- CALL CLEANUP FUNCTIONS HERE ---<<<
    # After all intended symlinks are created or updated by install_dotfiles,
    # you can now optionally scan for and remove unwanted symlinks.

    # Example call for removing stale symlinks:
    remove_stale_symlinks(
        DEFAULT_OPTIONS,
        prompt_before_scan=True,
        prompt_for_each_removal=True
    )

    # Example call for removing misplaced symlinks:
    # As discussed, the current logic for "misplaced" is very similar to "stale"
    # if they scan the same areas. If "misplaced" should scan *different* or
    # *broader* areas, the remove_misplaced_dotfile_symlinks function's
    # scanning part would need adjustment.
    remove_misplaced_dotfile_symlinks(
        DEFAULT_OPTIONS,
        prompt_before_scan=True,
        prompt_for_each_removal=True
    )

    print("\n------------------------------------")
    print("Dotfiles setup script finished.")
    if platform.system() == "Windows":
        print("REMINDER: For symlinks to work correctly on Windows without admin rights,")
        print("Developer Mode should be enabled (Settings -> Privacy & security -> For developers).")
        print("Alternatively, run this script as an Administrator.")


if __name__ == "__main__":
    main()
