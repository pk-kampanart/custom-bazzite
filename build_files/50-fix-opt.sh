#!/usr/bin/bash
set -xeuo pipefail

# Ported from ublue-os/bazzite-dx build_files/50-fix-opt.sh.
# /opt is a symlink to var/opt; /var is wiped at finalize, so move packaged /var/opt
# content into /usr/lib/opt and link it back at boot via tmpfiles.
mkdir -p /usr/lib/opt

shopt -s nullglob
for dir in /var/opt/*/; do
    [[ -d $dir ]] || continue
    dirname=$(basename "$dir")
    mv "$dir" "/usr/lib/opt/$dirname"
    echo "L+ /var/opt/$dirname - - - - /usr/lib/opt/$dirname" >>/usr/lib/tmpfiles.d/opt-fix.conf
done
