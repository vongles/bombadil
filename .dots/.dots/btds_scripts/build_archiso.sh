#!/usr/bin/env bash

set -e

echo "[L.VIII] Initializing Headless ArchISO Factory..."

# 1. SSH Key Generation (ED25519 Only)
mkdir -p .ssh_payload
echo "[L.XII] Generating keys for root and matt..."
ssh-keygen -t ed25519 -f .ssh_payload/id_ed25519_root -N "" -C "root@headless-t630"
ssh-keygen -t ed25519 -f .ssh_payload/id_ed25519_matt -N "" -C "matt@headless-t630"

# 2. Repository Creation
gh repo create archiso --private --confirm || echo "Repo already exists, proceeding..."
git init
git remote add origin $(gh repo view --json url -q .url)

# 3. Scaffold Archiso Structure (Standard Releng)
mkdir -p releng/airootfs/etc/systemd/system/getty@tty1.service.d/
mkdir -p releng/airootfs/usr/local/bin/
mkdir -p releng/airootfs/etc/ssh/
mkdir -p releng/airootfs/home/matt/.ssh/
mkdir -p releng/airootfs/root/.ssh/

# 4. Inject SSH Authorized Keys
cat .ssh_payload/id_ed25519_root.pub > releng/airootfs/root/.ssh/authorized_keys
cat .ssh_payload/id_ed25519_matt.pub > releng/airootfs/home/matt/.ssh/authorized_keys
chmod 700 releng/airootfs/root/.ssh
chmod 700 releng/airootfs/home/matt/.ssh

# 5. The Sonic Sentinel Script (UEFI vs BIOS)
cat << 'EOF' > releng/airootfs/usr/local/bin/sonic_check.sh
#!/bin/bash
modprobe pcspkr || true
if [ -d /sys/firmware/efi ]; then
    # FF7 Victory Fanfare (Simplified for beep)
    beep -f 440 -l 100 -n -f 440 -l 100 -n -f 440 -l 100 -n -f 349 -l 300 -n -f 415 -l 100 -n -f 440 -l 500
else
    # Sad Trombone
    beep -f 440 -l 400 -n -f 415 -l 400 -n -f 392 -l 400 -n -f 370 -l 800
    echo "CRITICAL: BIOS MODE DETECTED. CLEAR CMOS VIA JUMPER." > /dev/tty1
fi
EOF
chmod +x releng/airootfs/usr/local/bin/sonic_check.sh

# 6. User Provisioning & ACL Script
cat << 'EOF' > releng/airootfs/usr/local/bin/setup_users.sh
#!/bin/bash
# Create groups
for g in wheel sudoers admin coders; do groupadd -f $g; done

# Create matt
useradd -m -G wheel,sudoers,admin,coders -s /bin/bash matt
echo "matt:password123" | chpasswd
passwd -e matt

# Create coder service account
useradd -r -M -s /usr/bin/nologin -g coders coder

# Setup /src with ACLs
mkdir -p /src
chown coder:coders /src
chmod 775 /src
setfacl -R -m d:u:matt:rwx,d:u:coder:rwx,d:g:coders:rwx /src
EOF
chmod +x releng/airootfs/usr/local/bin/setup_users.sh

# 7. Systemd Auto-Start
cat << 'EOF' > releng/airootfs/etc/systemd/system/headless-init.service
[Unit]
Description=Headless Initializer
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/sonic_check.sh
ExecStart=/usr/local/bin/setup_users.sh
ExecStart=/usr/bin/systemctl start sshd

[Install]
WantedBy=multi-user.target
EOF

# 8. GitHub Actions Workflow
mkdir -p .github/workflows
cat << 'EOF' > .github/workflows/build.yml
name: Build ArchISO
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: archlinux:latest
      options: --privileged
    steps:
      - name: Install dependencies
        run: pacman -Syu --noconfirm archiso git
      - name: Checkout
        uses: actions/checkout@v3
      - name: Build ISO
        run: |
          cp -rv /usr/share/archiso/configs/releng/* releng/
          mkarchiso -v -w work/ -o out/ releng/
      - name: Upload Artifact
        uses: actions/upload-artifact@v3
        with:
          name: headless-arch-iso
          path: out/*.iso
EOF

# Final Push
git add .
git commit -m "feat: initial headless sonic-enabled scaffold"
git push origin main

echo "[L.XV] Scaffold Deployed. Check GitHub Actions to download your ISO."
echo "[WARNING] Your local private keys are in .ssh_payload/. SECURE THEM."
