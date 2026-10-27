#!/usr/bin/bash
set -xeuo pipefail

# Empty toplevel mountpoints baked into the image (bootc-filesystem(7) "Other toplevel directories");
# nix.mount/gnu.mount bind persistent dirs under /var onto them.
mkdir -p /nix /gnu
