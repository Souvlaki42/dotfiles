#!/usr/bin/env python3

from manager.install import install_dotfiles


def main() -> None:
  """Main function of the script."""
  print("==========================================")
  print("=== Dotfiles Installer Script ===")
  print("==========================================")
  install_dotfiles()


if __name__ == "__main__":
  main()
