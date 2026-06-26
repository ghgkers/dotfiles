#!/bin/bash

echo "Checking config for errors..."
if ! nix-instantiate --parse /etc/nixos/configuration.nix > /dev/null; then
    echo "ERROR: Syntax error in configuration.nix! Commit aborted."
    exit 1
fi

echo "Copying files..."
doas cp /etc/nixos/configuration.nix .
doas cp /etc/nixos/flake.nix .
doas cp /etc/nixos/flake.lock .
doas cp /etc/nixos/hosts/rog-strix/hardware-configuration.nix ./hosts/rog-strix/
doas cp /etc/nixos/hosts/rog-strix/hardware-spec.nix ./hosts/rog-strix/

cp -r ~/.config/hypr . 2>/dev/null || echo "Hypr config not found, skipping..."
cp -r ~/.config/waybar . 2>/dev/null || echo "Waybar config not found, skipping..."

git add .

msg="update config: $(date +'%Y-%m-%d %H:%M')"
if [ -n "$1" ]; then
  msg="$1"
fi
git commit -m "$msg"

git push origin main

echo "Done! Твой конфиг и flake.lock теперь на GitHub."
