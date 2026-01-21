#!/bin/bash

# Preflight checks and system preparation

check_internet() {
    log "Checking internet connection..."
    if ping -c 1 google.com &> /dev/null; then
        success "Internet connection available"
    else
        error "No internet connection. Please check your network."
    fi
}

check_permissions() {
    log "Checking permissions..."
    if [ "$EUID" -eq 0 ]; then
        error "Please do not run this script as root. Run as regular user."
    fi
}

check_disk_space() {
    log "Checking disk space..."
    local available=$(df / | awk 'NR==2 {print $4}')
    local required=2048000 # 2GB in KB
    
    if [ "$available" -lt "$required" ]; then
        error "Insufficient disk space. At least 2GB required."
    else
        success "Sufficient disk space available"
    fi
}

backup_existing_configs() {
    log "Backing up existing configurations..."
    
    local configs=("$HOME/.zshrc" "$HOME/.tmux.conf" "$HOME/.config/nvim")
    local backup_dir="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
    
    mkdir -p "$backup_dir"
    
    for config in "${configs[@]}"; do
        if [ -e "$config" ] && [ ! -L "$config" ]; then
            cp -r "$config" "$backup_dir/"
            success "Backed up $config"
        fi
    done
    
    success "Configurations backed up to $backup_dir"
}

check_dependencies() {
    log "Checking basic dependencies..."
    
    local deps=("curl" "git")
    for dep in "${deps[@]}"; do
        if ! command_exists "$dep"; then
            error "Missing dependency: $dep. Please install it first."
        fi
    done
    
    success "Basic dependencies available"
}

setup_directory_structure() {
    log "Setting up directory structure..."
    
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.local/share"
    mkdir -p "$HOME/.cache"
    
    success "Directory structure created"
}

detect_shell() {
    log "Detecting current shell..."
    current_shell=$(basename "$SHELL")
    log "Current shell: $current_shell"
}