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

# B.T.D.S. Shortcuts
alias px="pastex"
