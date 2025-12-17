#!/bin/bash
# ==============================================================================
# QUAESTOR PATCH: TEMPLATE SYNTAX FIX
# Authority: TH3 Arch1t3ct
# Function: Switch __[var]__ to {{ var }} for Bombadil/Tera compatibility
# ==============================================================================

set -e

REPO_ROOT="$HOME/src/aerarium"
BRANCH="imperium"

# COLORS
BLUE='\033[0;34m'
NC='\033[0m'
log() { echo -e "${BLUE}[PATCH]${NC} $1"; }

# 1. FIX EXPORTS TEMPLATE
log "Refining exports.bash template syntax..."
cat << 'EOF' > "$REPO_ROOT/bash/exports.bash"
# --- ENVIRONMENT ---
export HISTCONTROL='ignoreboth'
export HISTSIZE=100000
export HISTFILESIZE=200000
export GPG_TTY=$(tty)
export VISUAL=nvim
export EDITOR="$VISUAL"
export LANG="en_US.UTF-8"
export AER_PROFILE="{{ sys_id }}"

# Termux Runtime Fix
if [ -d "/data/data/com.termux" ]; then
    export VIMRUNTIME="/data/data/com.termux/files/usr/share/nvim/runtime/"
fi

# --- PATH CONSTRUCTION ---
add_to_path() {
    if [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="$1:$PATH"
    fi
}

add_to_path "/usr/sbin"
add_to_path "/usr/local/sbin"
add_to_path "/usr/local/bin"
add_to_path "$HOME/.config/composer/vendor/bin"
add_to_path "$HOME/.cargo/bin"
add_to_path "$HOME/.local/bin"
add_to_path "$HOME/platform-tools"
add_to_path "$HOME/.local/lib/npm/bin"
add_to_path "$HOME/.local/lib/go/bin"

export PATH
unset -f add_to_path

# Flavor Specific Exports
{{ sys_exports }}
EOF

# 2. FIX ALIASES TEMPLATE
log "Refining aliases.bash template syntax..."
cat << 'EOF' > "$REPO_ROOT/bash/aliases.bash"
# --- CORE ALIASES ---
alias ..='cd ..'
alias mkdir='mkdir -p -v'
alias df='df -h'
alias du='du -c -h'

# Navigation
alias ls='eza --icons --group'
alias ll='eza --long --header --git --icons --group'
alias la='eza --long --all --header --git --icons --group'
alias ltr='eza --tree --level=3 --icons'
alias grep='rg'

# Editors
alias vim='nvim'
alias vi='nvim'
alias v='nvim'

# Network/Process
alias ping='ping -c 3'
alias openports='ss --all --numeric --processes --ipv4 --ipv6'

# --- SYSTEM SPECIFIC (Bombadil Templates) ---
alias update='{{ sys_update }}'
alias root='{{ sys_root }}'
alias chconf='bombadil link --profiles "{{ sys_id }}"'

# Termux Specifics
if [ -d "/data/data/com.termux" ]; then
    alias sys='rish'
    android() { rish -c "$*"; }
    killapp() { [ -n "$1" ] && rish -c "am force-stop $1"; }
fi
EOF

# 3. COMMIT & PUSH
log "Syncing to Imperium..."
cd "$REPO_ROOT"
git add .
git commit -m "Fix: Switch template syntax to {{ var }} (Tera/Bombadil Std)" || true

if git remote get-url origin &>/dev/null; then
    git push origin "$BRANCH"
fi

# 4. RE-LINK
log "Relinking to force template render..."
# Clear cache to ensure re-render
rm -rf "$REPO_ROOT/.dots"

# Re-run install to parse new templates
bombadil install "$REPO_ROOT/bombadil.toml"
bombadil link --profiles arch_arm_proot

log "SUCCESS. Run 'source ~/.bashrc'"
