#!/bin/bash
set -e

echo "=== App Installation Script ==="

# ── Flatpak setup ──
echo "[1/4] Setting up Flatpak..."
sudo pacman -S --needed --noconfirm flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# ── Pacman apps ──
echo "[2/4] Installing pacman packages..."
sudo pacman -S --needed --noconfirm \
    vesktop-bin \
    steam \
    proton-vpn-gtk-app libappindicator-gtk3

# ── Flatpak apps ──
echo "[3/4] Installing Flatpak apps..."
flatpak install -y flathub md.obsidian.Obsidian
flatpak install -y flathub org.mozilla.Thunderbird
flatpak install -y flathub com.bitwarden.desktop

# ── Summary ──
echo ""
echo "[4/4] Installed:"
echo "  Obsidian        (flatpak)"
echo "  Thunderbird     (flatpak)"
echo "  Bitwarden       (flatpak)"
echo "  Vesktop         (pacman - CachyOS repo)"
echo "  Steam           (pacman)"
echo "  ProtonVPN       (pacman + tray icon support)"
echo ""
echo "=== Done! ==="
echo "Note: You may need to log out and back in for Flatpak apps"
echo "to appear in your app launcher."
