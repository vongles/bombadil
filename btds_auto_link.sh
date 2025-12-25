#!/bin/bash
set -e
echo ">> [B.T.D.S.] DETECTING ENVIRONMENT..."

# Detect Profile
if [ -d "/data/data/com.termux" ]; then
    PROFILE="termux"
elif uname -r | rg -q "microsoft|WSL"; then
    PROFILE="wsl"
elif [ -f /etc/os-release ] && rg -qE "Parrot|Kali" /etc/os-release; then
    PROFILE="parrot_vm"
else
    PROFILE="arch_x64"
fi

echo ">> SELECTED PROFILE: $PROFILE"
bombadil link -p "$PROFILE"
