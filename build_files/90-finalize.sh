#!/usr/bin/bash
set -xeuo pipefail

# Copy entries into /usr/lib/passwd and /usr/lib/group
# (copied from ublue-os/bazzite build_files/finalize).
relocate_accounts() {
    local etc="$1" lib="$2" shadow="$3" keep="$4" reset="$5"
    local out line name

    [ -f "$etc" ] || return 0
    out=$(grep -vE -- "$keep" "$etc") || true
    [ -n "$out" ] || return 0

    echo
    echo "Moving the following entries from ${etc} to ${lib}"
    echo "$out"

    { cat "$lib" 2>/dev/null || true; echo "$out"; } >"${lib}.new"
    mv -f "${lib}.new" "$lib"

    # Fail the build rather than ship an image where these went missing.
    while IFS= read -r line; do
        if ! grep -qxF -- "$line" "$lib"; then
            echo "ERROR: '${line}' did not persist in ${lib}" >&2
            return 1
        fi
    done <<<"$out"

    printf '%s\n' "$reset" >"$etc"

    if [ -f "$shadow" ]; then
        while IFS= read -r line; do
            name="${line%%:*}"
            sed -i "/^${name}:/d" "$shadow"
        done <<<"$out"
    fi
}

relocate_accounts /etc/passwd /usr/lib/passwd /etc/shadow \
    'root' 'root:x:0:0:root:/root:/bin/bash'
relocate_accounts /etc/group /usr/lib/group /etc/gshadow \
    'root|wheel' 'root:x:0:
wheel:x:10:'

# Extra lock files created by container processes that might cause issues
rm -rf \
    /etc/.pwd.lock \
    /etc/passwd- \
    /etc/group- \
    /etc/shadow- \
    /etc/gshadow- \
    /etc/subuid- \
    /etc/subgid-

# Rebuild initramfs (ublue-os/bazzite build_files/build-initramfs).
KVER=$(rpm -q --queryformat='%{evr}.%{arch}' kernel)
/usr/bin/dracut --no-hostonly --kver "$KVER" --reproducible --zstd -v --add ostree --add fido2 -f "/usr/lib/modules/$KVER/initramfs.img"
chmod 0600 "/usr/lib/modules/$KVER/initramfs.img"

dnf5 clean all

rm -rf /tmp/*
find /var -mindepth 1 -maxdepth 1 ! -name cache -exec rm -rf {} +
mkdir -p /var/tmp
chmod 1777 /var/tmp
