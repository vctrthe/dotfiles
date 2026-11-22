#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZPLUGINS="$HOME/.local/share/zsh/plugins"

log()  { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m[!] %s\033[0m\n' "$*"; }

[[ $EUID -ne 0 ]] || { echo "Run as regular user, not root."; exit 1; }
sudo -v

# ---------------------------------------------------------------
log "1/10 pacman.conf: Color + ParallelDownloads"
sudo sed -i 's/^#Color/Color/; s/^#ParallelDownloads.*/ParallelDownloads = 5/' /etc/pacman.conf

# ---------------------------------------------------------------
log "2/10 Official repo packages"
sudo pacman -Syu --needed --noconfirm - < "$DOTFILES/pkglist.txt"

# ---------------------------------------------------------------
log "3/10 yay (AUR helper)"
if ! command -v yay >/dev/null; then
  tmp="$(mktemp -d)"
  git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
  rm -rf "$tmp"
fi

# ---------------------------------------------------------------
log "4/10 AUR packages (interactive: inspect PKGBUILD if asked)"
yay -S --needed - < "$DOTFILES/aurlist.txt"

# ---------------------------------------------------------------
log "5/10 Toolchain, outside pacman (Go tooling, Node, etc.)"
export PATH="$HOME/go/bin:$PATH"
go install github.com/go-delve/delve/cmd/dlv@latest
go install golang.org/x/tools/cmd/goimports@latest
eval "$(fnm env --shell bash)"
fnm install --lts
fnm default lts-latest
npm install -g npm pnpm prettier

# ---------------------------------------------------------------
log "6/10 Zsh Plugin"
mkdir -p "$ZPLUGINS"
for repo in Aloxaf/fzf-tab zdharma-continuum/fast-syntax-highlighting romkatv/powerlevel10k; do
  dir="$ZPLUGINS/${repo#*/}"
  [[ -d $dir ]] || git clone --depth 1 "https://github.com/$repo" "$dir"
done

# ---------------------------------------------------------------
command -v ya >/dev/null && ya pkg install || true
log "7/10 Symlink dotfiles (stow)"
if [[ -n "$(git -C "$DOTFILES" status --porcelain)" ]]; then
  warn "There are changes that haven't been commited in the dotfiles. Commit first, then re-run."
  exit 1
fi
# Make target folder first so stow symlink-ing per file, not every folder
mkdir -p ~/.config ~/.config/systemd/user ~/.local/bin
# Every level-1 folder is stow package, except system/ and .git
mapfile -t STOW_PKGS < <(find "$DOTFILES" -mindepth 1 -maxdepth 1 -type d \
  ! -name '.git' ! -name 'system' -printf '%f\n' | sort)
(cd "$DOTFILES" && stow --adopt -t "$HOME" "${STOW_PKGS[@]}")
git -C "$DOTFILES" restore .

# ---------------------------------------------------------------
log "8/10 System files (/etc)"
while IFS= read -r -d '' src; do
  dst="${src#"$DOTFILES/system"}"
  if [[ $dst == /etc/ssh/* && ! -s "$HOME/.ssh/authorized_keys" ]]; then
    warn "Skipping $dst: ~/.ssh/authorized_keys is not available (avoid lockout from SSH)."
    continue
  fi
  sudo install -D -m 644 "$src" "$dst"
done < <(find "$DOTFILES/system" -type f -print0)
sudo sshd -t
sudo nft -c -t /etc/nftables.conf

# ---------------------------------------------------------------
log "9/10 System and User service"
sudo systemctl enable --now NetworkManager sshd systemd-timesyncd nftables paccache.timer
sudo systemctl enable systemd-boot-update.service
sudo systemctl reload sshd
systemctl --user daemon-reload
systemctl --user enable --now sys-check.timer

# ---------------------------------------------------------------
log "10/10 GTK themes, cursor, and default shell"
gsettings set org.gnome.desktop.interface gtk-theme    'adw-gtk3-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface icon-theme   'Papirus-Dark'
gsettings set org.gnome.desktop.interface font-name    'Noto Sans 10'
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'
gsettings set org.gnome.desktop.interface cursor-size  24
[[ "$(getent passwd "$USER" | cut -d: -f7)" == */zsh ]] || chsh -s /usr/bin/zsh

log "Done."
echo "Reboot, then login in TTY1: Hyprland start automatically."
echo "Open nvim once, to install plugins (vim.pack will ask for confirmation)."
