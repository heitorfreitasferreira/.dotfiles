#!/bin/bash

# Main package installation script
# This orchestrates all package installations

# Install AUR helper for Arch Linux
install_yay

# Core development tools
install_git
install_zsh
install_neovim
install_tmux
install_fzf
install_zoxide
install_eza
install_wget
install_go
install_docker
install_stow
install_java

# Additional utilities
install_additional_tools

# Version managers
install_nvm
install_sdkman

# Custom tools
install_opencode

success "All packages installation completed!"