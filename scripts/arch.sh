#!/bin/bash

# Atualizar os repositórios e o sistema
sudo pacman -Syu
sudo pacman -S --needed base-devel git

git clone https://aur.archlinux.org/yay.git /tmp && cd /tmp && makepkg -si

# Instalar programas base
sudo pacman -S git exa docker fzf zoxide neovim zsh zsh-completions entr tmux jdk-openjdk stow go openssh --noconfirm

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

chsh -s /usr/bin/zsh
zsh

# Exibir versões instaladas
git --version
fzf --version
zoxide --version
zsh --version
tmux -V
java --version
go version

stow .

source ~/.zshrc

tmux source ~/.config/tmux.conf
