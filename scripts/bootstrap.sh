#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -eEo pipefail

# Define setup locations
export DEV_SETUP_PATH="$HOME/.local/share/dev-setup"
export DEV_SETUP_INSTALL="$DEV_SETUP_PATH/install"
export DEV_SETUP_LOG_FILE="/var/log/dev-setup-install.log"

# Create setup directory
mkdir -p "$DEV_SETUP_PATH"
mkdir -p "$(dirname "$DEV_SETUP_LOG_FILE")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
  echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

success() {
  echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] ✓ $1${NC}"
}

warning() {
  echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] ⚠ $1${NC}"
}

error() {
  echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ✗ $1${NC}"
  exit 1
}

# Detect OS
detect_os() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ -f /etc/arch-release ]; then
      echo "arch"
    elif [ -f /etc/debian_version ]; then
      echo "debian"
    else
      error "Unsupported Linux distribution"
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  else
    error "Unsupported operating system: $OSTYPE"
  fi
}

# Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Install package based on OS
install_package() {
  local package=$1
  local os=$(detect_os)

  log "Installing $package..."

  case $os in
  arch)
    if command_exists yay; then
      yay -S --noconfirm "$package" || sudo pacman -S --noconfirm "$package"
    else
      sudo pacman -S --noconfirm "$package"
    fi
    ;;
  debian)
    if command_exists nix; then
      nix-env -iA nixpkgs."$package" 2>/dev/null || sudo apt install -y "$package"
    else
      sudo apt install -y "$package"
    fi
    ;;
  macos)
    if command_exists brew; then
      brew install "$package"
    else
      error "Homebrew not found. Please install Homebrew first."
    fi
    ;;
  esac

  success "$package installed"
}

# Helper functions
source helpers/all.sh

# Preflight checks
source preflight/all.sh

# Package installation
source packaging/main.sh

# Configuration setup
source config/all.sh

# Login shell configuration
source login/all.sh

# Post-installation tasks
source post-install/all.sh

log "Development environment setup complete!"

