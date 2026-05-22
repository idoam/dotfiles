#!/bin/bash

set -o xtrace

# copy dotfiles
mkdir -p ~/.local/share/fonts/
cp fonts/* ~/.local/share/fonts/*
cp -r pictures/ ~/.config/
cp -r i3 ~/.config/
cp -r rofi ~/.config/
cp -r picom ~/.config/
cp zshrc ~/.zshrc

# load gnome-terminal config
cat termconfig | dconf load /org/gnome/terminal/legacy/

# install packages
packages=""
while read -r pkg; do
  [ -z "$pkg" ] && continue
  packages="$packages $pkg"
done < packages.txt
sudo apt update && sudo apt install -y $packages

# oh-my-zsh and plugins
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions          ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git  ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# kubectl & helm
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.36/deb/Release.key      | gpg --dearmor -o /usr/share/keyrings/kubernetes.gpg
curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor -o /usr/share/keyrings/helm.gpg
sudo chmod 644 /usr/share/keyrings/kubernetes.gpg
sudo chmod 644 /usr/share/keyrings/helm.gpg
echo 'deb [signed-by=/usr/share/keyrings/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/v1.36/deb/ /'                | sudo tee /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main' | sudo tee /etc/apt/sources.list.d/helm.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/helm.list
sudo apt update && sudo apt install -y kubectl helm

# betterlockscreen
wget https://raw.githubusercontent.com/betterlockscreen/betterlockscreen/main/install.sh -O - -q | bash -s user
betterlockscreen --update ~/.config/pictures/leaves.jpg1
