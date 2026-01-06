#!/usr/bin/env bash
# uninstall.sh - dotfiles uninstallation using stow, unstow all package directories found
set -e

DOTFILES_DIR="$HOME/.dotfiles"

if ! command -v stow &> /dev/null; then
  echo "error: GNU Stow is not installed"
  exit 1
fi

cd "$DOTFILES_DIR"

echo "removing stowed symlinks..."
for package in "$DOTFILES_DIR"/*; do
  if [ -d "$package" ]; then
    pkg_name="$(basename "$package")"
    echo "unstowing $pkg_name..."
    stow -D -v "$pkg_name" 2>/dev/null || echo "  (package was not stowed or already removed)"
  fi
done

echo "uninstallation complete!"
