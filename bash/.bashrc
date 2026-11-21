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
