#!/bin/bash

echo "Checking config for errors..."[cite: 1]
if ! nix-instantiate --parse /etc/nixos/configuration.nix > /dev/null; then[cite: 1]
    echo "ERROR: Syntax error in configuration.nix! Commit aborted."[cite: 1]
    exit 1[cite: 1]
fi

echo "Copying files..."[cite: 1]
doas cp /etc/nixos/configuration.nix .
doas cp /etc/nixos/flake.nix .
doas cp /etc/nixos/flake.lock .[cite: 1]
doas cp /etc/nixos/hosts/rog-strix/hardware-configuration.nix ./hosts/rog-strix/
doas cp /etc/nixos/hosts/rog-strix/hardware-spec.nix ./hosts/rog-strix/

cp -r ~/.config/hypr . 2>/dev/null || echo "Hypr config not found, skipping..."[cite: 1]
cp -r ~/.config/waybar . 2>/dev/null || echo "Waybar config not found, skipping..."[cite: 1]

git add .[cite: 1]

msg="update config: $(date +'%Y-%m-%d %H:%M')"[cite: 1]
if [ -n "$1" ]; then[cite: 1]
  msg="$1"[cite: 1]
fi
git commit -m "$msg"[cite: 1]

git push origin main[cite: 1]

echo "Done! Твой конфиг и flake.lock теперь на GitHub."[cite: 1]
