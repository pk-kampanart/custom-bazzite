#!/usr/bin/bash
set -xeuo pipefail

: "${IMAGE_NAME:?IMAGE_NAME must be set}"
: "${IMAGE_VENDOR:?IMAGE_VENDOR must be set}"
export IMAGE_NAME IMAGE_VENDOR

cp -avf /ctx/system_files/. /

# The nvidia image is a desktop image; desktop autologin only applies to the deck-based AMD image.
if [[ $IMAGE_NAME == *nvidia* ]]; then
    rm -f /etc/bazzite/desktop_autologin
fi

echo 'import "/usr/share/ublue-os/just/96-custom.just"' >>/usr/share/ublue-os/justfile

for script in /ctx/build_files/[0-9][0-9]-*.sh; do
    echo "::group::Executing $(basename "$script")"
    "$script"
    echo "::endgroup::"
done
