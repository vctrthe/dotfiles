# ===== System =====
alias c='clear'
alias reload='source ~/.zshrc'
alias zshconfig='nvim ~/.zshrc'
alias aliasconfig='nvim ~/.aliases.zsh'

# ===== Git =====
alias gs='git status'
alias glog='git log --oneline --graph --decorate'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gco='git checkout'
alias gsw='git switch'
alias gcb='git switch -c'
alias gb='git branch'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git pull'
alias gp='git push'

# ===== Maintenance Arch =====
alias up='yay && echo "--- pacnew ---" && pacdiff -o && zplug-update'
alias orphans='pacman -Qdtq'
alias errors='systemctl --failed; journalctl -p 3 -b --no-pager | tail -30'
alias hyprlog='tail -50 "$XDG_RUNTIME_DIR/hypr/$(ls -t "$XDG_RUNTIME_DIR/hypr" | head -1)/hyprland.log"'

# ===== Tools =====
alias lg='lazygit'

# yazi
y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}
