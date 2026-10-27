#!/usr/bin/bash
set -xeuo pipefail

# image-name and os-release stay untouched: base scripts branch on *deck*/*nvidia* in image-name.
IMAGE_INFO=/usr/share/ublue-os/image-info.json
IMAGE_REF="ostree-unverified-registry:ghcr.io/${IMAGE_VENDOR}/${IMAGE_NAME}"

tmp=$(mktemp)
jq --arg vendor "$IMAGE_VENDOR" --arg ref "$IMAGE_REF" \
    '.["image-vendor"] = $vendor | .["image-ref"] = $ref' \
    "$IMAGE_INFO" >"$tmp"
mv -f "$tmp" "$IMAGE_INFO"
chmod 0644 "$IMAGE_INFO"
