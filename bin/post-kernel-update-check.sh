#!/usr/bin/env bash
set -u

LATEST_KERNEL=$(ls /lib/modules | sort -V | tail -1)
RUNNING_KERNEL=$(uname -r)
EXPECTED_SIGNER="fedora_1785655683_864076c0"
OK=1

if [ "$LATEST_KERNEL" = "$RUNNING_KERNEL" ]; then
    echo "Checking kernel ${LATEST_KERNEL} (currently running)"
else
    echo "Checking kernel ${LATEST_KERNEL} (installed, not yet booted — running ${RUNNING_KERNEL})"
fi
echo

echo -n "vmd driver in initramfs... "
if sudo lsinitrd "/boot/initramfs-${LATEST_KERNEL}.img" 2>/dev/null | grep -qi vmd; then
    echo "OK"
    VMD_MISSING=0
else
    echo "MISSING"
    OK=0
    VMD_MISSING=1
fi

echo -n "nvidia module signed... "
SIGNER=$(sudo modinfo -k "$LATEST_KERNEL" nvidia 2>/dev/null | sed -n 's/^signer:[[:space:]]*//p')
if [ -n "$SIGNER" ]; then
    echo "OK ($SIGNER)"
    if [ "$SIGNER" != "$EXPECTED_SIGNER" ]; then
        echo "  note: differs from expected ($EXPECTED_SIGNER) — MOK key may have changed"
    fi
    SIGNER_MISSING=0
else
    echo "UNSIGNED"
    OK=0
    SIGNER_MISSING=1
fi

echo -n "nvidia module version... "
VERSION=$(modinfo -k "$LATEST_KERNEL" -F version nvidia 2>/dev/null)
if [ -n "$VERSION" ]; then
    echo "$VERSION"
else
    echo "NOT FOUND"
    OK=0
fi

echo

if [ "$OK" -eq 1 ]; then
    if [ "$LATEST_KERNEL" = "$RUNNING_KERNEL" ]; then
        echo "All checks passed. Running kernel is healthy."
    else
        echo "All checks passed. Safe to reboot into ${LATEST_KERNEL}."
    fi
else
    echo "Problems found."
    echo

    if [ "${VMD_MISSING:-0}" -eq 1 ]; then
        read -rp "Regenerate initramfs with vmd pinned? [y/N] " ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then
            echo 'force_drivers+=" vmd nvme "' | sudo tee /etc/dracut.conf.d/99-vmd.conf >/dev/null
            sudo dracut -f --regenerate-all
            if sudo lsinitrd "/boot/initramfs-${LATEST_KERNEL}.img" 2>/dev/null | grep -qi vmd; then
                echo "vmd now present."
            else
                echo "Still missing — investigate manually."
            fi
            echo
        fi
    fi

    if [ "${SIGNER_MISSING:-0}" -eq 1 ]; then
        read -rp "Rebuild and sign the nvidia module (akmods)? [y/N] " ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then
            sudo akmods --force --rebuild
            SIGNER=$(sudo modinfo -k "$LATEST_KERNEL" nvidia 2>/dev/null | sed -n 's/^signer:[[:space:]]*//p')
            if [ -n "$SIGNER" ]; then
                echo "Now signed: $SIGNER"
            else
                echo "Still unsigned — investigate manually."
            fi
            echo
        fi
    fi

    echo "Re-run this script to verify."
fi

echo
read -n 1 -s -r -p "Press any key to close..."
echo
