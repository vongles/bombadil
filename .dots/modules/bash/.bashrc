#!/usr/bin/env bash
# Aerarium Orchestrator

# 1. Guard
case "$-" in *i*) ;; *) return;; esac

# 2. History & Options
shopt -s histappend checkwinsize globstar
bind '"\e[A": history-search-backward' 2>/dev/null
bind '"\e[B": history-search-forward' 2>/dev/null

# 3. Load Aerarium Modules
CFG_DIR="$HOME/.config/bash"
[ -f "$CFG_DIR/exports.bash" ] && source "$CFG_DIR/exports.bash"
[ -f "$CFG_DIR/aliases.bash" ] && source "$CFG_DIR/aliases.bash"

# 4. Prompt Strategy (Starship Priority)
# We prioritize Starship because we just forged the config for it
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
elif [ -f "$CFG_DIR/prompt.bash" ]; then
    source "$CFG_DIR/prompt.bash"
fi

# 5. Tools
[ -f /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion
[[ -x "$(command -v zoxide)" ]] && eval "$(zoxide init bash)"
[[ -x "$(command -v direnv)" ]] && eval "$(direnv hook bash)"

echo "Kernel: $(uname -r) | Shell: Bash ${BASH_VERSION}"
alias px=pastex
