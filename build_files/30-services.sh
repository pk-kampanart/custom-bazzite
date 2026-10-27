#!/usr/bin/bash
set -xeuo pipefail

systemctl enable \
    docker.socket \
    podman.socket \
    libvirt-workaround.service \
    custom-dx-groups.service \
    nix.mount \
    gnu.mount
