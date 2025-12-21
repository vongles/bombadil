# --- ENVIRONMENT ---
export HISTCONTROL='ignoreboth'
export HISTSIZE=100000
export HISTFILESIZE=200000
export GPG_TTY=$(tty)
export VISUAL=nvim
export EDITOR="$VISUAL"
export LANG="en_US.UTF-8"
export AER_PROFILE="arch_x64"
export GEMINI_API_KEY="AIzaSyCQNez6_sFl2koNAXOWFi7dplSWzh0UTyY"
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
export ARCH_ARCH=x86_64

# --- B.T.D.S. OMNISYSTEM ---
export PATH="$HOME/.local/bin/btds:$PATH"
