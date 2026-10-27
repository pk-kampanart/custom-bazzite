# custom-bazzite

Personal [Bazzite](https://github.com/ublue-os/bazzite) images with a developer
stack modelled on [Bluefin-DX](https://github.com/ublue-os/bluefin) and
[Bazzite-DX](https://github.com/ublue-os/bazzite-dx). Built on the official
`ghcr.io/ublue-os` images only.

## Images

| Image | Base | Hardware |
|---|---|---|
| `ghcr.io/pk-kampanart/bazzite-custom` | `ghcr.io/ublue-os/bazzite-deck:stable` | AMD desktop (KDE Plasma, ROCm) |
| `ghcr.io/pk-kampanart/bazzite-custom-nvidia` | `ghcr.io/ublue-os/bazzite-nvidia:stable` | GTX 1050 (Pascal) laptop, closed NVIDIA driver (KDE Plasma) |

Tags: `stable`, `stable-<fedora>.<YYYYMMDD>`, `<fedora>`.

## Differences from Bazzite-DX / Bluefin-DX

- Bluefin-DX system stack: Incus/LXC, libvirt/QEMU (plus virt-v2v, guestfs-tools),
  Docker CE, Podman machine, Cockpit, bcc/bpftrace/trace-cmd, udica.
- ROCm (HIP, OpenCL, rocm-smi) on the AMD image only.
- No preinstalled Flatpak or Homebrew packages and no VS Code. Install what you
  need afterwards (see ujust recipes below).
- No extra VPN or mesh packages are added; the base image's VPN packages are
  untouched. Packages you have layered with `rpm-ostree install` stay layered
  across the rebase.
- Empty `/nix` and `/gnu` mountpoints, bind-mounted from `/var/home/nix` and
  `/var/gnu`, for Nix and Guix.
- The AMD image is built on the deck image but autologins to Plasma desktop.
  Steam Game Mode switching still works; change the default session with
  `ujust set-default-game-mode` or `ujust set-default-desktop`.

## Rebase

```bash
# AMD desktop
rpm-ostree rebase ostree-unverified-registry:ghcr.io/pk-kampanart/bazzite-custom:stable
# NVIDIA laptop
rpm-ostree rebase ostree-unverified-registry:ghcr.io/pk-kampanart/bazzite-custom-nvidia:stable
```

Reboot afterwards. Images are not signed.

## ujust recipes

- `ujust install-system-flatpaks` — install Bazzite's default KDE Flatpak set.
- `ujust install-dev-flatpaks` — install the Bluefin-DX developer Flatpaks
  (Podman Desktop, DevToolbox, Clapgrep, Embellish, Builder).
- `ujust dx-group` — add your user to the `docker`, `incus-admin`, `libvirt`
  and `dialout` groups.

VS Code: `brew install --cask ublue-os/tap/visual-studio-code-linux`, or pick it in `bbrew`.

## Nix

Use the [Determinate Nix installer](https://github.com/DeterminateSystems/nix-installer).
The image ships `nix.mount` binding `/var/home/nix` to `/nix`, the same
persistence path the installer's ostree planner uses. An existing
`/etc/systemd/system/nix.mount` or `/etc/fstab` entry overrides the shipped
unit, so existing installs keep working. An old `nix-directory.service` from
the installer skips itself because `/nix` already exists.

## Guix

Use the official `guix-install.sh`. `/gnu` is bind-mounted from `/var/gnu`, so
the store lands in `/var/gnu/store`; `/var/guix` is created by the installer.

## Build cadence

GitHub Actions builds both images:

- every 6 hours, rebuilding an image only when its base image digest changed
  (stored in the `io.github.pk-kampanart.base-digest` label);
- on every push to `main` (Markdown-only changes excluded);
- on manual `workflow_dispatch`.

Pull requests build without pushing.
