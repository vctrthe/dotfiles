# dotfiles: Arch Linux ARM + Hyprland (UTM, Apple Silicon)

## for reproducible purposes

## Components

- Hyprland 0.57 (Lua config)
- waybar
- foot
- wofi
- mako
- hyprlock/hypridle
- zsh + powerlevel10k
- neovim (kickstart, vim.pack)
- Go
- Node (fnm)
- lazygit
- yazi
- nftables
- systemd user timer

## VM (UTM)

- Virtualize -> Linux, backend **QEMU** (not Apple Virtualization), UEFI.
- Display: `virtio-gpu-gl-pci`, **Retina Mode** active.
- ISO: archboot aarch64.

## Installation

1. Manual base install: partition (EFI 1G + root), `pacstrap`, locale/hostname, user `victor` in `wheel` group, sudo, NetworkManager, sshd, systemd-boot.
2. From Mac: `ssh-copy-id` to VM (before bootstrap, so SSH hardening can be set).
3. From VM:

```bash
sudo pacman -S --needed git stow
git clone https://github.com/<user>/dotfiles ~/dotfiles
~/dotfiles/bootstrap.sh
```

4. Reboot -> Login to TTY1

## Structure

- Level-1 folder (except `system/`) = GNU Stow packages, symlink-ed to `$HOME`.
- `system/` = files for `/etc`, installed by `bootstrap.sh`.
- `pkglist.txt`/`aurlist.txt` updated automatically by pacman hook.

## Routines

- `up`: system udpate + AUR + plugin zsh, then display `.pacnew`
- `sys-check.timer`: daily notification if there are any updates or dotfiles haven't been commited.
