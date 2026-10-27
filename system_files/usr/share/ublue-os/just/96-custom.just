# vim: set ft=make :

# Install Bazzite's default system Flatpaks (delegates to base hidden recipe in 80-bazzite.just)
[group('apps')]
install-system-flatpaks:
    #!/usr/bin/bash
    ujust _install-system-flatpaks

# Install Bluefin-DX developer Flatpaks (Podman Desktop, DevToolbox, Clapgrep, Embellish, Builder)
[group('apps')]
install-dev-flatpaks:
    #!/usr/bin/bash
    flatpak install --system -y flathub io.podman_desktop.PodmanDesktop me.iepure.devtoolbox de.leopoldluley.Clapgrep io.github.getnf.embellish org.gnome.Builder

# Copied from ublue-os/bazzite-dx 95-bazzite-dx.just
# Configure docker,incus-admin,libvirt, container manager, serial permissions
[group('system')]
dx-group:
    #!/usr/bin/pkexec bash
    append_group() {
        local group_name="$1"
        if ! grep -q "^$group_name:" /etc/group; then
            echo "Appending $group_name to /etc/group"
            grep "^$group_name:" /usr/lib/group | sudo tee -a /etc/group > /dev/null
        fi
    }

    GROUPS_ADD=("docker" "incus-admin" "libvirt" "dialout")

    for GROUP_ADD in "${GROUPS_ADD[@]}" ; do
        append_group $GROUP_ADD
        usermod -aG $GROUP_ADD {{ `id -un` }}
    done

    echo "Reboot system and log back in to use docker, libvirt, incus, and serial connections."
