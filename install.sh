#!/bin/bash

# set -o xtrace

# copy dotfiles
mkdir -p ~/.local/share/fonts/
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

# docker
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# kubectl & helm
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.36/deb/Release.key      | sudo gpg --dearmor -o /usr/share/keyrings/kubernetes.gpg
curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/helm.gpg

sudo chmod 644 /usr/share/keyrings/kubernetes.gpg
sudo chmod 644 /usr/share/keyrings/helm.gpg
echo 'deb [signed-by=/usr/share/keyrings/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/v1.36/deb/ /'                | sudo tee /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main' | sudo tee /etc/apt/sources.list.d/helm.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/helm.list
sudo apt update && sudo apt install -y kubectl helm

# uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# neovim
curl -fLo /tmp/nvim-linux-x86_64.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf /tmp/nvim-linux-x86_64.tar.gz
rm /tmp/nvim-linux-x86_64.tar.gz
git clone git@github.com:idoam/nvim.git ~/.config/nvim

# node
PROFILE=/dev/null bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.7/install.sh)"
export NVM_DIR="$HOME/.nvm" && . "$NVM_DIR/nvm.sh"
nvm install --lts

# tree-sitter
mkdir -p ~/.local/bin
curl -fL https://github.com/tree-sitter/tree-sitter/releases/download/v0.27.0/tree-sitter-linux-x64.gz \
  | gunzip > ~/.local/bin/tree-sitter
chmod +x ~/.local/bin/tree-sitter

# betterlockscreen
sudo git clone https://github.com/Raymo111/i3lock-color.git /opt/i3lock-color && cd /opt/i3lock-color && ./install-i3lock-color.sh
wget https://raw.githubusercontent.com/betterlockscreen/betterlockscreen/main/install.sh -O - -q | bash -s user
betterlockscreen --update ~/.config/pictures/leaves.jpg

i3-msg restart
