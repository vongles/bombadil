#!/bin/bash

echo ">> [L.VIII] Consolidating B.T.D.S. Repository..."

# 1. CLEANUP DIRECTORY COLLISIONS
# This is the critical fix for the IoError.
echo ">> [CLEANUP] Removing directory-file collisions..."
rm -rf ~/.local/bin/btds
rm -rf ~/btds_scripts
rm -f ~/pastex

# 2. REMOVE LEGACY GHOSTS
echo ">> [CLEANUP] Nuking Aerarium/Legacy remnants..."
rm -f ~/.bashrc
rm -f ~/.config/bash/aliases.bash
rm -f ~/.config/bash/exports.bash
rm -f ~/.config/starship.toml

# 3. REINSTALL CORE CONFIG
echo ">> [INSTALL] Installing B.T.D.S. Bombadil Core..."
cd ~/btds_dots || exit 1
# This sets the source of truth to the btds_dots folder.
bombadil install bombadil.toml

# 4. PROFILE LINKING
if [ -d "/data/data/com.termux" ] || uname -m | grep -q "aarch64"; then
    echo ">> [PROFILE] Linking: arch_arm_proot"
    bombadil link -p arch_arm_proot --force
else
    echo ">> [PROFILE] Linking: arch_x64"
    bombadil link -p arch_x64 --force
fi

# 5. FINAL RELOAD
echo ">> [SUCCESS] B.T.D.S. OmniSystem Harmonized."
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
    echo ">> [SYSTEM] Shell reloaded with new identity."
fi
