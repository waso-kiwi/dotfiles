#!/bin/bash
set -e

DOTFILES_REPO="https://github.com/waso-kiwi/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

echo "=== CachyOS + DMS Setup Script ==="

# ── Clone dotfiles repo ──
echo "[1/3] Cloning dotfiles..."
sudo pacman -S --needed --noconfirm git

if [ -d "$DOTFILES_DIR" ]; then
    echo "  $DOTFILES_DIR already exists, pulling latest..."
    git -C "$DOTFILES_DIR" pull
else
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# ── Neovim + your config ──
echo "[2/3] Installing Neovim + your nvim config..."
sudo pacman -S --needed --noconfirm neovim

if [ -d "$HOME/.config/nvim" ]; then
    echo "  ~/.config/nvim already exists, backing up to ~/.config/nvim.bak"
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
fi

mkdir -p "$HOME/.config"
cp -r "$DOTFILES_DIR/nvim/.config/nvim" "$HOME/.config/nvim"

# ── Japanese Input (fcitx5 + Mozc) ──
echo "[3/3] Installing fcitx5 + Mozc..."
sudo pacman -S --needed --noconfirm fcitx5-im fcitx5-mozc

# /etc/environment — append only if not already present
echo "  Configuring /etc/environment..."
for line in "GTK_IM_MODULE=fcitx" "QT_IM_MODULE=fcitx" "XMODIFIERS=@im=fcitx"; do
    grep -qxF "$line" /etc/environment || echo "$line" | sudo tee -a /etc/environment > /dev/null
done

echo ""
echo "=== Done! ==="
echo "Next steps:"
echo "  1. Reboot (so /etc/environment takes effect)"
echo "  2. Run: fcitx5-configtool"
echo "     → Add 'Mozc' as an input method"
echo "  3. Open Neovim once to let plugins bootstrap"
