#!/bin/bash

echo ">> [L.VIII] Initiating Total Sovereignty Script..."

# 1. REMOVE DIRECTORY COLLISIONS
# Bombadil cannot symlink a directory if a directory already exists at the target.
echo ">> [CLEANUP] Nuking target directory collisions..."
rm -rf ~/.local/bin/btds
rm -rf ~/btds_scripts

# 2. REMOVE LEGACY SYMLINKS
echo ">> [CLEANUP] Removing Aerarium/Legacy remnants..."
rm -f ~/.bashrc
rm -f ~/.config/bash/aliases.bash
rm -f ~/.config/bash/exports.bash
rm -f ~/.config/starship.toml

# 3. REINSTALL CORE CONFIG
echo ">> [INSTALL] Installing B.T.D.S. Bombadil Core..."
cd ~/btds_dots || exit 1
# Force update the config in ~/.config/bombadil.toml
bombadil install bombadil.toml

# 4. PROFILE LINKING
if [ -d "/data/data/com.termux" ] || uname -m | grep -q "aarch64"; then
    echo ">> [PROFILE] Linking: arch_arm_proot"
    bombadil link -p arch_arm_proot --force
else
    echo ">> [PROFILE] Linking: arch_x64"
    bombadil link -p arch_x64 --force
fi

# 5. FINAL HANDSHAKE
echo ">> [SUCCESS] B.T.D.S. OmniSystem Harmonized."
# Ensure bashrc exists before sourcing to avoid the last error
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
    echo ">> [SYSTEM] Shell reloaded."
fi
