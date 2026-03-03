export ZSH="$HOME/.zsh"
export PATH="$HOME/.local/bin:$PATH"

# -----------------------------
# Core shell behavior
# -----------------------------

HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY

setopt AUTO_CD
setopt INTERACTIVE_COMMENTS

bindkey -v

# -----------------------------
# Completion
# -----------------------------

autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# -----------------------------
# Word movement / deletion
# -----------------------------

bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

bindkey '^[^[[D' backward-word
bindkey '^[^[[C' forward-word
bindkey '^[b' backward-word
bindkey '^[f' forward-word

bindkey '^H' backward-kill-word
bindkey '^[[8;5u' backward-kill-word
bindkey '^[[127;5u' backward-kill-word

bindkey '^[[3;5~' kill-word

bindkey -M viins '^[[1;5A' up-line-or-history
bindkey -M viins '^[[1;5B' down-line-or-history
bindkey -M main  '^[[1;5A' up-line-or-history
bindkey -M main  '^[[1;5B' down-line-or-history

# -----------------------------
# External tools
# -----------------------------

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh

# -----------------------------
# Aliases
# -----------------------------

alias ls='eza --icons=auto'
alias ll='eza -lh --icons=auto'
alias la='eza -lah --icons=auto'
alias lt='eza --tree --level=2 --icons=auto'
alias lsa='eza -a --icons=auto'
alias lta='eza --tree --level=2 -a --icons=auto'

alias fd='fdfind'
alias bat='batcat'

# -----------------------------
# Functions
# -----------------------------

ff() {
  local file
  file=$(find . -type f 2>/dev/null | sed 's|^\./||' | fzf --preview 'bat --style=numbers --color=always --line-range=:200 {} 2>/dev/null || sed -n "1,200p" {}')
  [[ -n "$file" ]] && printf '%s\n' "$file"
}

# -----------------------------
# Plugins
# -----------------------------

source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source ~/.zsh/plugins/fzf-tab/fzf-tab.plugin.zsh

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down

bindkey -M viins '^[[A' history-substring-search-up
bindkey -M viins '^[[B' history-substring-search-down
bindkey -M viins '^[OA' history-substring-search-up
bindkey -M viins '^[OB' history-substring-search-down

bindkey -M main '^[[A' history-substring-search-up
bindkey -M main '^[[B' history-substring-search-down
bindkey -M main '^[OA' history-substring-search-up
bindkey -M main '^[OB' history-substring-search-down

source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# -----------------------------
# Prompt
# -----------------------------

eval "$(starship init zsh)"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Machine-local overrides (not tracked in dotfiles repo)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
