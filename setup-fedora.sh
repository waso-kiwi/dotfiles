#!/bin/bash
# ─────────────────────────────────────────────────────────────────────
# Fedora Workstation 44 — Full setup script
# Adapted from CachyOS setup-app.sh, expanded with Fedora essentials.
# Target hardware: Asus Zenbook S13 OLED 2020 (Intel Tiger Lake, no dGPU)
#
# Usage: bash setup-app.sh
#   (Do NOT run with sudo. Script handles privilege escalation.)
# ─────────────────────────────────────────────────────────────────────

set -e

echo "╔══════════════════════════════════════════════════╗"
echo "║   Fedora Workstation Setup                       ║"
echo "╚══════════════════════════════════════════════════╝"

# ── 0. System update ──
echo ""
echo "[0/10] Updating system..."
sudo dnf upgrade -y

# ── 1. DNF speed tweaks ──
# Most are already defaults in F41+, but explicit is better.
echo ""
echo "[1/10] Configuring DNF for speed..."
DNF_CONF=/etc/dnf/dnf.conf
sudo grep -q '^max_parallel_downloads' "$DNF_CONF" || \
    echo 'max_parallel_downloads=10' | sudo tee -a "$DNF_CONF" > /dev/null
sudo grep -q '^fastestmirror' "$DNF_CONF" || \
    echo 'fastestmirror=True' | sudo tee -a "$DNF_CONF" > /dev/null
sudo grep -q '^defaultyes' "$DNF_CONF" || \
    echo 'defaultyes=True' | sudo tee -a "$DNF_CONF" > /dev/null

# ── 2. Firmware updates ──
# Asus pushes BIOS/EC firmware via LVFS. Worth doing on a fresh install.
echo ""
echo "[2/10] Refreshing firmware metadata..."
sudo fwupdmgr refresh --force || true
sudo fwupdmgr get-updates || true
echo "      (To apply firmware updates later: sudo fwupdmgr update)"

# ── 3. RPM Fusion (free + non-free) ──
echo ""
echo "[3/10] Enabling RPM Fusion repos..."
sudo dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

# ── 4. Multimedia + Intel hardware video acceleration ──
# Swap stripped ffmpeg-free for the full ffmpeg.
# Add Intel iHD driver for hardware-accelerated video decode (Tiger Lake+).
# Without this: YouTube + video playback hammers the CPU and drains battery.
echo ""
echo "[4/10] Installing full codecs + Intel HW video acceleration..."
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
sudo dnf group upgrade -y multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf group upgrade -y sound-and-video || true
sudo dnf install -y \
    intel-media-driver \
    libva-utils \
    libavcodec-freeworld

# ── 5. Flathub (unfiltered) ──
echo ""
echo "[5/10] Configuring Flathub (full catalog)..."
flatpak remote-modify --no-filter --enable flathub 2>/dev/null || \
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# ── 6. ProtonVPN official repo ──
echo ""
echo "[6/10] Setting up Proton repo..."
PROTON_REL="protonvpn-stable-release-1.0.3-1.noarch.rpm"
PROTON_URL="https://repo.protonvpn.com/fedora-$(rpm -E %fedora)-stable/protonvpn-stable-release/${PROTON_REL}"
if ! rpm -q protonvpn-stable-release > /dev/null 2>&1; then
    cd /tmp
    wget -q "${PROTON_URL}"
    sudo dnf install -y "./${PROTON_REL}"
    rm -f "./${PROTON_REL}"
    cd - > /dev/null
fi
sudo dnf check-update -y --refresh || true

# ── 7. Core DNF packages ──
# pacman → dnf translation:
#   steam                     → steam (RPM Fusion non-free)
#   proton-vpn-gtk-app        → proton-vpn-gnome-desktop (Proton repo)
#   libappindicator-gtk3      → same name
#   vesktop-bin               → moved to Flatpak
#
# Plus additions for a usable workstation:
#   gamemode, mangohud        → gaming perf governor + FPS overlay
#   git, gh                   → version control + GitHub CLI
#   @development-tools        → gcc, make, autoconf, etc. (build deps)
#   nodejs                    → for web dev work
#   gnome-tweaks, extensions  → GUI customization + tray icon support
#   jetbrains-mono-fonts      → nice monospace for terminals/editors
echo ""
echo "[7/10] Installing core packages..."
sudo dnf install -y \
    steam \
    proton-vpn-gnome-desktop \
    libappindicator-gtk3 \
    gnome-shell-extension-appindicator \
    gnome-tweaks \
    gamemode \
    mangohud \
    git \
    gh \
    nodejs \
    jetbrains-mono-fonts \
    fira-code-fonts \
    htop \
    wget \
    curl
sudo dnf group install -y development-tools

# ── 8. Asus tools (asusctl) ──
# Provides battery charge limit, keyboard backlight, fan curves on supported models.
# Skipping supergfxctl: Zenbook S13 OLED 2020 has no discrete GPU.
echo ""
echo "[8/10] Installing Asus tools (asusctl)..."
sudo dnf copr enable -y lukenukem/asus-linux
sudo dnf install -y asusctl
echo "      To set battery charge limit to 80%: sudo asusctl -c 80"

# ── 9. Flatpak apps ──
echo ""
echo "[9/10] Installing Flatpak apps..."
flatpak install -y --noninteractive flathub md.obsidian.Obsidian
flatpak install -y --noninteractive flathub org.mozilla.Thunderbird
flatpak install -y --noninteractive flathub com.bitwarden.desktop
flatpak install -y --noninteractive flathub dev.vencord.Vesktop

# ── 10. Summary ──
echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║   [10/10] Done!                                  ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
echo "Installed:"
echo "  System         DNF tuned, RPM Fusion, full codecs, Intel HW accel"
echo "  Apps (RPM)     Steam, ProtonVPN GUI, gamemode, mangohud"
echo "  Apps (Flatpak) Obsidian, Thunderbird, Bitwarden, Vesktop"
echo "  Dev            git, gh, @development-tools, nodejs"
echo "  Asus           asusctl (battery limit, backlight)"
echo "  Fonts          JetBrains Mono, Fira Code"
echo ""
echo "═══ POST-INSTALL ═══"
echo ""
echo "  1. REBOOT — codec swap + RPM Fusion + asusctl all need it."
echo ""
echo "  2. Open the 'Extensions' app and toggle ON:"
echo "       - AppIndicator and KStatusNotifierItem Support"
echo "     (needed for ProtonVPN tray icon)"
echo ""
echo "  3. Set battery charge limit to extend battery lifespan:"
echo "       sudo asusctl -c 80"
echo ""
echo "  4. Apply firmware updates if any are pending:"
echo "       sudo fwupdmgr update"
echo ""
echo "  5. Verify Intel HW video acceleration works:"
echo "       vainfo | grep iHD"
echo "     Should show profiles (H264, HEVC, VP9, AV1)."
echo ""
echo "  6. Sign in to Flatpak apps as needed."
