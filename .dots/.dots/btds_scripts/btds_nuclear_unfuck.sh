#!/bin/bash

echo ">> [L.VIII] Initiating Nuclear Un-fuck..."

# 1. PURGE LEGACY SYMLINKS
echo ">> [CLEANUP] Removing Aerarium remnants..."
rm -f ~/.bashrc
rm -f ~/.config/bash/aliases.bash
rm -f ~/.config/bash/exports.bash
rm -f ~/.config/starship.toml

# 2. FORCE B.T.D.S. INSTALL
echo ">> [INSTALL] Installing B.T.D.S. Bombadil Core..."
cd ~/btds_dots
# This maps ~/btds_dots/bombadil.toml to ~/.config/bombadil.toml
bombadil install bombadil.toml

# 3. DETECT & LINK
if [ -d "/data/data/com.termux" ] || uname -m | grep -q "aarch64"; then
    echo ">> [PROFILE] Linking: arch_arm_proot"
    bombadil link -p arch_arm_proot --force
else
    echo ">> [PROFILE] Linking: arch_x64"
    bombadil link -p arch_x64 --force
fi

echo ">> [SUCCESS] B.T.D.S. OmniSystem Harmonized. Reloading..."
source ~/.bashrc
