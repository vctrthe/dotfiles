#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
# ===== Maintenance aliases =====
alias up='yay && echo "--- pacnew ---" && pacdiff -o'
alias orphans='pacman -Qdtq'
alias errors='systemctl --failed; journalctl -p 3 -b --no-pager | tail -30'
alias hyprlog='tail -50 "$XDG_RUNTIME_DIR/hypr/$(ls -t "$XDG_RUNTIME_DIR/hypr" | head -1)/hyprland.log"'
# ===== Dev environment =====
export EDITOR=nvim
export VISUAL=nvim

# Go: binary `go install` inside ~/go/bin
export PATH="$HOME/go/bin:$PATH"

# fnm: auto change Node version when `cd` to folder that has `.nvmrc` / `.node_version`
eval "$(fnm env --use-on-cd --shell bash)"

# ===== Fastfetch =====
__ff_enabled() {
  [[ $- == *i* ]] && [[ -z "$NVIM" ]] && [[ -n "$WAYLAND_DISPLAY" || -n "$SSH_TTY" ]]
}

if __ff_enabled; then
  fastfetch

  clear() { command clear; fastfetch; }
  bind -x '"\C-l": clear'
fi
