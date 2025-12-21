#!/bin/bash
echo ">> [L.VIII] Purging legacy Bombadil state..."
rm -rf ~/.dots ~/.config/bombadil
cd ~/btds_dots

# Auto-detect if we are in proot or on the T630
if [ -d "/data/data/com.termux" ] || uname -m | grep -q "aarch64"; then
    echo ">> [L.VIII] Proot/ARM environment detected."
    bombadil link -p arch_arm_proot --force
else
    echo ">> [L.VIII] X64/Native environment detected."
    bombadil link -p arch_x64 --force
fi

source ~/.bashrc
echo ">> [SUCCESS] System identities harmonized. Run 'px' again to test."
