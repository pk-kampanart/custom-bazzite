#!/usr/bin/bash
set -xeuo pipefail

dnf5 -y install \
    bcc \
    bpftrace \
    cascadia-code-fonts \
    cockpit-bridge \
    cockpit-machines \
    cockpit-networkmanager \
    cockpit-ostree \
    cockpit-podman \
    cockpit-selinux \
    cockpit-storaged \
    cockpit-system \
    dbus-x11 \
    edk2-ovmf \
    git-subtree \
    guestfs-tools \
    incus \
    incus-agent \
    libvirt \
    libvirt-nss \
    lxc \
    numactl \
    osbuild-selinux \
    p7zip \
    p7zip-plugins \
    podman-machine \
    qemu \
    qemu-char-spice \
    qemu-device-display-virtio-gpu \
    qemu-device-display-virtio-vga \
    qemu-device-usb-redirect \
    qemu-img \
    qemu-kvm \
    qemu-system-x86-core \
    qemu-user-binfmt \
    qemu-user-static \
    trace-cmd \
    udica \
    util-linux-script \
    virt-v2v \
    wtype \
    ydotool

# Docker CE, repo enabled only for the install (ublue-os/bazzite-dx 20-install-apps.sh).
docker_pkgs=(
    containerd.io
    docker-buildx-plugin
    docker-ce
    docker-ce-cli
    docker-compose-plugin
)
dnf5 config-manager addrepo --from-repofile="https://download.docker.com/linux/fedora/docker-ce.repo"
dnf5 config-manager setopt docker-ce-stable.enabled=0
dnf5 -y install --enable-repo="docker-ce-stable" "${docker_pkgs[@]}"
rm -f /etc/yum.repos.d/docker-ce.repo

# ROCm for the AMD image (ublue-os/bazzite-dx 20-install-apps.sh).
if [[ $IMAGE_NAME != *nvidia* ]]; then
    dnf5 -y remove mesa-libOpenCL
    dnf5 --setopt=install_weak_deps=False -y install \
        rocm-hip \
        rocm-opencl \
        rocm-clinfo \
        rocm-smi
fi

# Newer selinux-policy from the dx packages overwrites rpm-ostree's subs_dist fix
# (ublue-os/bluefin build_files/dx/00-dx.sh).
sed -i 's|^/var/home[[:space:]]\+/home$|/home /var/home|' /etc/selinux/targeted/contexts/files/file_contexts.subs_dist

if [[ -e /etc/yum.repos.d/docker-ce.repo ]]; then
    echo "ERROR: /etc/yum.repos.d/docker-ce.repo must not ship in the image" >&2
    exit 1
fi
