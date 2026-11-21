# ===== Fastfetch header =====
if [[ -o interactive && -z $NVIM && ( -n $WAYLAND_DISPLAY || -n $SSH_TTY ) ]]; then
  fastfetch
  typeset -g __FF_ENABLED=1
fi

# ===== Powerlevel10k instant prompt =====
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ===== History =====
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt share_history hist_ignore_all_dups hist_ignore_space hist_reduce_blanks extended_history
setopt auto_cd interactive_comments

# ===== Completion =====
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'

# ===== Plugins =====
ZPLUGINS="$HOME/.local/share/zsh/plugins"
source "$ZPLUGINS/fzf-tab/fzf-tab.plugin.zsh"
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source "$ZPLUGINS/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"

zplug-update() {
  for d in "$ZPLUGINS"/*(/); do
    print -P "%F{blue}→ ${d:t}%f"
    git -C "$d" pull --ff-only
  done
}

# ===== Tools =====
source <(fzf --zsh)
eval "$(fnm env --use-on-cd --shell zsh)"

# ===== Prompt =====
source "$ZPLUGINS/powerlevel10k/powerlevel10k.zsh-theme"
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ===== Aliases & secrets =====
[[ -f ~/.aliases.zsh ]] && source ~/.aliases.zsh

# ===== clear dan Ctrl+L menampilkan ulang fastfetch =====
if (( ${+__FF_ENABLED} )); then
  clear() { command clear; fastfetch }
  _ff_clear_screen() { command clear; fastfetch; zle reset-prompt }
  zle -N _ff_clear_screen
  bindkey '^L' _ff_clear_screen
fi

