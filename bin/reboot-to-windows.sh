#!/usr/bin/env bash
set -u

ENTRY_ID='osprober-efi-3444-E9E2'

zenity --question \
    --title="Reboot to Windows" \
    --text="Reboot into Windows now?\n\nAll unsaved work will be lost." \
    --width=300 || exit 0

PASSWORD=$(zenity --password --title="Authenticate") || exit 0

sudo -S grub2-reboot "$ENTRY_ID" <<< "$PASSWORD" >/dev/null 2>&1
STATUS=$?
unset PASSWORD

if [ "$STATUS" -ne 0 ]; then
    zenity --error --title="Reboot to Windows" \
        --text="Failed to set the boot entry (wrong password?). Nothing was rebooted.\n\nManual fallback:\nsudo grub2-reboot $ENTRY_ID && systemctl reboot -i"
    exit 1
fi

systemctl reboot -i
