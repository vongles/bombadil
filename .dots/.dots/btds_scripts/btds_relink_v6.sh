#!/bin/bash

echo ">> [L.VIII] Harmonizing Bombadil Profiles..."

# Move into the dots directory to ensure bombadil sees the files
cd ~/btds_dots || { echo "ERR: ~/btds_dots not found"; exit 1; }

# Detection Logic
if [ -d "/data/data/com.termux" ] || uname -m | grep -q "aarch64"; then
    echo ">> [STATUS] Environment: PROOT / ARM"
    # Attempt link, fallback to install if state is corrupted
    bombadil link -p arch_arm_proot --force || bombadil install bombadil.toml
else
    echo ">> [STATUS] Environment: NATIVE / X64"
    bombadil link -p arch_x64 --force || bombadil install bombadil.toml
fi

echo ">> [SUCCESS] Identity confirmed. Reloading shell..."
source ~/.bashrc
