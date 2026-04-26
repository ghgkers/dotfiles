#!/bin/bash

# 1. Копируем актуальные конфиги в папку репозитория
echo "copying files..."
sudo cp /etc/nixos/configuration.nix .
sudo cp /etc/nixos/hardware-configuration.nix .
cp -r ~/.config/hypr .
cp -r ~/.config/waybar .

# 2. Добавляем изменения в Git
git add .

# 3. Делаем коммит (если не ввел сообщение, будет стандартное)
msg="update config: $(date +'%Y-%m-%d %H:%M')"
if [ -n "$1" ]; then
  msg="$1"
fi
git commit -m "$msg"

# 4. Отправляем в облако
git push origin main

echo "Done! Твой закат и конфиги теперь на GitHub."
