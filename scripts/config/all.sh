#!/bin/bash

# Configuration setup and dotfiles management

setup_dotfiles() {
  log "Setting up dotfiles with GNU Stow..."

  # Navigate to dotfiles directory
  cd "$HOME/.dotfiles"

  # Ensure we're in the right directory
  if [ ! -f "bootstrap.sh" ]; then
    error "Not in the correct dotfiles directory"
  fi

  # Restore stow if needed
  if ! command_exists stow; then
    install_stow
  fi

  # Stow all configurations
  stow . || warning "Some stow operations may have conflicts"

  success "Dotfiles configured with Stow"
}

setup_tmux_plugins() {
  log "Setting up Tmux Plugin Manager..."

  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    success "TPM installed"
  else
    success "TPM already exists"
  fi
}

setup_zinit() {
  log "Setting up Zinit plugin manager..."

  ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

  if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
    success "Zinit installed"
  else
    success "Zinit already exists"
  fi
}

setup_neovim_config() {
  log "Setting up Neovim configuration..."

  # Ensure nvim config directory exists
  mkdir -p "$HOME/.config/nvim"

  # Install LazyVim if not present
  if [ ! -f "$HOME/.config/nvim/init.lua" ]; then
    git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
    rm -rf "$HOME/.config/nvim/.git"
    success "LazyVim starter configuration installed"
  else
    success "Neovim configuration already exists"
  fi
}

setup_git_config() {
  log "Configuring Git..."

  if ! git config --global user.email; then
    git config --global user.email "heitor.ff@hotmail.com"
    git config --global user.name "heitorfreitasferreira"
    success "Git configured"
  else
    success "Git already configured"
  fi
}

configure_shell_integrations() {
  log "Configuring shell integrations..."

  # Create necessary directories
  mkdir -p "$HOME/.cache"

  # Set up FZF integration
  if command_exists fzf; then
    log "Setting up FZF integration..."
    # FZF integration will be handled by the .zshrc
    success "FZF integration configured"
  fi

  # Set up Zoxide integration
  if command_exists zoxide; then
    log "Setting up Zoxide integration..."
    # Zoxide integration will be handled by the .zshrc
    success "Zoxide integration configured"
  fi
}

create_ssh_key() {
  log "Setting up SSH key..."

  if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    ssh-keygen -t ed25519 -C "heitor.ff@hotmail.com" -f "$HOME/.ssh/id_ed25519" -N ""
    success "SSH key created"

    log "SSH public key:"
    cat "$HOME/.ssh/id_ed25519.pub"
    log "Add this key to your GitHub account"
  else
    success "SSH key already exists"
  fi
}

