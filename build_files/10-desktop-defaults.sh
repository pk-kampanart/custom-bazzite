#!/usr/bin/bash
set -xeuo pipefail

# Only the AMD image is deck-based; the nvidia image already has desktop defaults.
if [[ $IMAGE_NAME == *nvidia* ]]; then
    exit 0
fi

# Restore UUPD update timer, Input Remapper and tuned.
# Copied from ublue-os/bazzite-dx build_files/20-install-apps.sh (restore section only;
# sddm/steamos-manager-powerstation are kept so Game Mode switching keeps working).
sed -i 's@^NoDisplay=true@NoDisplay=false@' /usr/share/applications/input-remapper-gtk.desktop
# Undo the Hidden=true that the bazzite-deck stage inserts (ublue-os/bazzite Containerfile).
sed -i '/^Hidden=true$/d' /etc/xdg/autostart/input-remapper-autoload.desktop
systemctl enable input-remapper.service
systemctl enable uupd.timer

systemctl mask powerstation.service
systemctl enable tuned.service
systemctl enable tuned-ppd.service
