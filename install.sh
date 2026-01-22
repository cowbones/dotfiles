#!/usr/bin/env bash
#
# Author: Devon Casey <me@devoncasey.com>
# Date: Jan 6th, 2026
# License: MIT
# 
set -e

DOTFILES_DIR="$HOME/.dotfiles"

help() {
  cat << EOF
Script to install dotfiles using GNU Stow. Folders within the dotfiles directory
represent different packages to be stowed.

Usage: $0 [options]

Options:
  -b, --base     Install only core dotfiles
  -f, --full     Install all dotfiles
  -h, --help     Show this help message
EOF
  exit 0
}

if [ "$#" -ne 1 ]; then
  help
fi

MODE="$1"

if [ "$MODE" = "-h" ] || [ "$MODE" = "--help" ]; then
  help
fi

detect_package_manager() {
  if command -v apt &> /dev/null; then
    echo "apt"
  elif command -v dnf &> /dev/null; then
    echo "dnf"
  elif command -v pacman &> /dev/null; then
    echo "pacman"
  else
    echo "unknown"
  fi
}

PKG_MANAGER=$(detect_package_manager)

install_package() {
  local pkg="$1"
  echo "installing $pkg..."
  case "$PKG_MANAGER" in
    apt)
      sudo apt update && sudo apt install -y "$pkg"
      ;;
    dnf)
      sudo dnf install -y "$pkg"
      ;;
    pacman)
      sudo pacman -Sy --noconfirm "$pkg"
      ;;
    brew)
      brew install "$pkg"
      ;;
    *)
      echo "unknown package manager. please install $pkg manually."
      return 1
      ;;
  esac
}

if ! command -v stow &> /dev/null; then
  echo "stow is not installed."
  echo "would you like to install stow now? (y/n)"
  read -r reply
  if [[ "$reply" =~ ^[Yy]$ ]]; then
    install_package stow
  else
    echo "error: Stow was not found. exiting..."
    exit 1
  fi
fi

cd "$DOTFILES_DIR"

declare -A base_packages=(
  ["starship"]="starship"
  ["git"]="git"
  ["fish"]="fish"
  ["nvim"]="neovim"
  ["vim"]="vim"
)

declare -A full_packages=(
  ["kitty"]="kitty"
)

if [ "$MODE" = "-b" ] || [ "$MODE" = "--base" ]; then
  declare -A packages=()
  for key in "${!base_packages[@]}"; do
    packages[$key]="${base_packages[$key]}"
  done
elif [ "$MODE" = "-f" ] || [ "$MODE" = "--full" ]; then
  declare -A packages=()
  for key in "${!base_packages[@]}"; do
    packages[$key]="${base_packages[$key]}"
  done
  for key in "${!full_packages[@]}"; do
    packages[$key]="${full_packages[$key]}"
  done
else
  help
fi

echo "installing packages: ${!packages[*]}"

for stow_name in "${!packages[@]}"; do
  pkg_name="${packages[$stow_name]}"
  
  if [ -z "$pkg_name" ]; then
    continue
  fi
  
  if ! command -v "$stow_name" &> /dev/null; then
    echo "$stow_name not found on system."
    echo "would you like to install $pkg_name? (y/n)"
    read -r install_reply
    if [[ "$install_reply" =~ ^[Yy]$ ]]; then
      install_package "$pkg_name"
    else
      echo "skipping $stow_name installation."
    fi
  fi
done

for stow_name in "${!packages[@]}"; do
  if [ -d "$stow_name" ]; then
    echo "stowing $stow_name..."
    if stow_output=$(stow -nv "$stow_name" 2>&1); then
      stow -v "$stow_name"
    else
      if echo "$stow_output" | grep -q 'would cause conflicts'; then
        echo "$stow_output"
        read -rp "conflicts detected for $stow_name. overwrite conflicting files? (y/n) " overwrite
        if [[ "$overwrite" =~ ^[Yy]$ ]]; then
          echo "$stow_output" | grep 'cannot stow' | sed -n 's/.*over existing target \(.*\) since.*/\1/p' | while read -r file; do
            file=$(echo "$file" | xargs)
            if [ -e "$HOME/$file" ]; then
              rm -f "$HOME/$file"
              echo "removed $HOME/$file"
            fi
          done
          stow -v "$stow_name"
        else
          echo "skipped $stow_name due to conflicts."
        fi
      else
        echo "error: stowing $stow_name failed:"
        echo "$stow_output"
      fi
    fi
  else
    echo "warning: package directory $stow_name not found, skipping..."
  fi
done

if [[ -n "${packages[fish]}" ]]; then
  echo "installing fisher..."
  fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"

  if [ -f "$HOME/.config/fish/fish_plugins" ]; then
    echo "syncing fisher plugins..."
    fish -c "fisher update"
  fi
fi

echo ""
echo "installation complete!"
echo "restart your shell or run: exec fish"
