#!/usr/bin/env bash
# Sets up symlinks from $HOME into this repo, and re-installs the same
# packages/repos/flatpaks that were present when the lists were last dumped.
#
# Safe to re-run any time. If a real file already exists where a symlink
# should go, it gets renamed to <file>.bak-<timestamp> instead of deleted.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

link() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -e "$dest" ]; then
    echo "Backing up existing $dest -> $dest.bak-$TIMESTAMP"
    mv "$dest" "$dest.bak-$TIMESTAMP"
  fi

  ln -s "$src" "$dest"
  echo "Linked $dest -> $src"
}

echo "== Linking config/ =="
for path in "$REPO_DIR"/config/*; do
  name="$(basename "$path")"
  link "$path" "$HOME/.config/$name"
done

echo "== Linking home/ dotfiles =="
for path in "$REPO_DIR"/home/.*; do
  name="$(basename "$path")"
  [ "$name" = "." ] && continue
  [ "$name" = ".." ] && continue
  link "$path" "$HOME/$name"
done

echo "== Linking bin/ scripts =="
mkdir -p "$HOME/.local/bin"
for path in "$REPO_DIR"/bin/*; do
  name="$(basename "$path")"
  chmod +x "$path"
  link "$path" "$HOME/.local/bin/$name"
done

echo
read -rp "Install packages from packages/ lists now? [y/N] " ans
if [[ "$ans" =~ ^[Yy]$ ]]; then
  if [ -f "$REPO_DIR/packages/copr-repos.txt" ]; then
    echo "== Enabling copr repos =="
    while read -r repo; do
      [ -z "$repo" ] && continue
      sudo dnf copr enable -y "$repo"
    done < "$REPO_DIR/packages/copr-repos.txt"
  fi

  if [ -f "$REPO_DIR/packages/dnf-packages.txt" ]; then
    echo "== Installing dnf packages =="
    sudo dnf install -y $(cat "$REPO_DIR/packages/dnf-packages.txt")
  fi

  if [ -f "$REPO_DIR/packages/flatpak-packages.txt" ]; then
    echo "== Installing flatpaks =="
    while read -r app; do
      [ -z "$app" ] && continue
      flatpak install -y flathub "$app"
    done < "$REPO_DIR/packages/flatpak-packages.txt"
  fi
fi

echo
echo "Done. Log out/in (or reboot) for niri/shell changes to fully apply."
