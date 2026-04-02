#!/bin/bash
set -e

DOTFILES_REPO="https://github.com/waso-kiwi/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

echo "=== CachyOS Niri Setup Script ==="

# ── Clone dotfiles repo ──
echo "[1/5] Cloning dotfiles..."
sudo pacman -S --needed --noconfirm git

if [ -d "$DOTFILES_DIR" ]; then
    echo "  $DOTFILES_DIR already exists, pulling latest..."
    git -C "$DOTFILES_DIR" pull
else
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# ── Neovim + your config ──
echo "[2/5] Installing Neovim + your nvim config..."
sudo pacman -S --needed --noconfirm neovim

if [ -d "$HOME/.config/nvim" ]; then
    echo "  ~/.config/nvim already exists, backing up to ~/.config/nvim.bak"
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
fi

mkdir -p "$HOME/.config"
cp -r "$DOTFILES_DIR/nvim/.config/nvim" "$HOME/.config/nvim"

# ── Niri config from dotfiles ──
echo "[3/5] Installing your niri config..."

if [ -d "$HOME/.config/niri" ]; then
    echo "  ~/.config/niri already exists, backing up to ~/.config/niri.bak"
    mv "$HOME/.config/niri" "$HOME/.config/niri.bak"
fi

cp -r "$DOTFILES_DIR/niri" "$HOME/.config/niri"

# ── Japanese Input (fcitx5 + Mozc) ──
echo "[4/5] Installing fcitx5 + Mozc..."
sudo pacman -S --needed --noconfirm fcitx5-im fcitx5-mozc

# /etc/environment — append only if not already present
echo "  Configuring /etc/environment..."
for line in "GTK_IM_MODULE=fcitx" "QT_IM_MODULE=fcitx" "XMODIFIERS=@im=fcitx"; do
    grep -qxF "$line" /etc/environment || echo "$line" | sudo tee -a /etc/environment > /dev/null
done

# Patch niri config: add fcitx5 autostart if missing
NIRI_CFG="$HOME/.config/niri/config.kdl"
if [ -f "$NIRI_CFG" ]; then
    if ! grep -q 'spawn-at-startup "fcitx5"' "$NIRI_CFG"; then
        TMPFILE=$(mktemp)
        {
            echo 'spawn-at-startup "fcitx5" "-d"'
            echo ""
            cat "$NIRI_CFG"
        } > "$TMPFILE"
        mv "$TMPFILE" "$NIRI_CFG"
        echo "  Patched: added fcitx5 spawn-at-startup"
    fi

    # Set JP keyboard layout if not already present
    if ! grep -q 'layout "jp"' "$NIRI_CFG"; then
        if grep -q 'input {' "$NIRI_CFG"; then
            if grep -q 'layout' "$NIRI_CFG"; then
                sed -i 's/layout "[^"]*"/layout "jp"/' "$NIRI_CFG"
            else
                sed -i '/keyboard {/a\            xkb {\n                layout "jp"\n            }' "$NIRI_CFG"
            fi
        else
            cat >> "$NIRI_CFG" << 'BLOCK'

input {
    keyboard {
        xkb {
            layout "jp"
        }
    }
}
BLOCK
        fi
        echo "  Patched: set keyboard layout to JP"
    fi
else
    echo "  WARNING: config.kdl not found in your niri dotfiles, skipping patches"
fi

# ── SDDM Astronaut Theme ──
echo "[5/5] Installing sddm-astronaut-theme..."

sudo pacman -S --needed --noconfirm sddm qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg

THEME_DIR="/usr/share/sddm/themes/sddm-astronaut-theme"
if [ -d "$THEME_DIR" ]; then
    echo "  Theme already installed, pulling latest..."
    sudo git -C "$THEME_DIR" pull
else
    sudo git clone -b master --depth 1 \
        https://github.com/keyitdev/sddm-astronaut-theme.git "$THEME_DIR"
fi

sudo cp -r "$THEME_DIR"/Fonts/* /usr/share/fonts/
sudo sed -i 's|^ConfigFile=.*|ConfigFile=Themes/astronaut.conf|' "$THEME_DIR/metadata.desktop"

sudo mkdir -p /etc/sddm.conf.d
echo "[Theme]
Current=sddm-astronaut-theme" | sudo tee /etc/sddm.conf > /dev/null

echo "[General]
InputMethod=qtvirtualkeyboard" | sudo tee /etc/sddm.conf.d/virtualkbd.conf > /dev/null

sudo systemctl enable sddm.service 2>/dev/null || true

echo ""
echo "=== Done! ==="
echo "Next steps:"
echo "  1. Reboot (so SDDM theme + /etc/environment take effect)"
echo "  2. Run: fcitx5-configtool"
echo "     → Add 'Mozc' as an input method"
echo "  3. Open Neovim once to let plugins bootstrap"
echo ""
echo "Preview SDDM theme without rebooting:"
echo "  sddm-greeter-qt6 --test-mode --theme $THEME_DIR/"
