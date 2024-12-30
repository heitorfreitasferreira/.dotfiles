#!/bin/bash

# Atualizar os repositórios e o sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependências necessárias para o Nix
sudo apt install -y curl build-essential xz-utils

# Instalar o Nix
sh <(curl -L https://nixos.org/nix/install) --no-daemon
# Ativar o Nix
. ~/.nix-profile/etc/profile.d/nix.sh

# Instalar programas base usando Nix
sudo nix-env -iA git eza docker fzf zoxide neovim zsh zsh-completions nixpkgs.tmux nixpkgs.openjdk nixpkgs.stow nixpkgs.go nixpkgs.openssh tldr ranger python3 node unzip ripgrep make gcc deno nvm btop lazygit fd

git config --global user.email "heitor.ff@hotmail.com"
git config --global user.name "heitorfreitasferreira"

# Clonar e instalar o tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Alterar o shell padrão para zsh
chsh -s /usr/bin/zsh
zsh

cd ~/.dotfiles/

# Configurar stow
stow .
cd ~

# Carregar configurações do zsh
source ~/.zshrc

# Carregar configurações do tmux
tmux source ~/.config/tmux.conf

sudo reboot
