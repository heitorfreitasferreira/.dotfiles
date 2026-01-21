#!/bin/bash

# Package verification and installation helpers

install_git() {
    if ! command_exists git; then
        install_package git
    else
        success "Git already installed"
    fi
}

install_zsh() {
    if ! command_exists zsh; then
        install_package zsh
        install_package zsh-completions
    else
        success "Zsh already installed"
    fi
}

install_neovim() {
    if ! command_exists nvim; then
        case $(detect_os) in
            arch)
                install_package neovim
                ;;
            debian)
                install_package neovim
                ;;
            macos)
                install_package neovim
                ;;
        esac
    else
        success "Neovim already installed"
    fi
}

install_tmux() {
    if ! command_exists tmux; then
        install_package tmux
    else
        success "Tmux already installed"
    fi
}

install_fzf() {
    if ! command_exists fzf; then
        case $(detect_os) in
            arch)
                install_package fzf
                ;;
            debian)
                install_package fzf
                ;;
            macos)
                install_package fzf
                ;;
        esac
    else
        success "FZF already installed"
    fi
}

install_zoxide() {
    if ! command_exists zoxide; then
        install_package zoxide
    else
        success "Zoxide already installed"
    fi
}

install_eza() {
    if ! command_exists eza; then
        case $(detect_os) in
            arch)
                install_package eza
                ;;
            debian)
                install_package eza
                ;;
            macos)
                install_package eza
                ;;
        esac
    else
        success "Eza already installed"
    fi
}

install_wget() {
    if ! command_exists wget; then
        install_package wget
    else
        success "Wget already installed"
    fi
}

install_go() {
    if ! command_exists go; then
        install_package go
    else
        success "Go already installed"
    fi
}

install_docker() {
    if ! command_exists docker; then
        install_package docker
    else
        success "Docker already installed"
    fi
}

install_stow() {
    if ! command_exists stow; then
        install_package stow
    else
        success "GNU Stow already installed"
    fi
}

install_java() {
    if ! command_exists java; then
        case $(detect_os) in
            arch)
                install_package jdk-openjdk
                ;;
            debian)
                install_package openjdk
                ;;
            macos)
                install_package openjdk
                ;;
        esac
    else
        success "Java already installed"
    fi
}

install_additional_tools() {
    # Tools mentioned in your debian.sh
    local tools=("curl" "build-essential" "xz-utils" "unzip" "ripgrep" "make" "gcc" "btop" "lazygit" "fd" "tldr" "ranger" "python3" "node" "deno")
    
    for tool in "${tools[@]}"; do
        if ! command_exists "$tool"; then
            log "Installing $tool..."
            case $(detect_os) in
                arch)
                    # Map package names for Arch
                    case $tool in
                        build-essential) install_package base-devel ;;
                        xz-utils) install_package xz ;;
                        *) install_package "$tool" ;;
                    esac
                    ;;
                debian)
                    install_package "$tool"
                    ;;
                macos)
                    install_package "$tool"
                    ;;
            esac
        else
            success "$tool already installed"
        fi
    done
}

install_nvm() {
    if [ ! -d "$HOME/.nvm" ]; then
        log "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        success "NVM installed"
    else
        success "NVM already installed"
    fi
}

install_sdkman() {
    if [ ! -d "$HOME/.sdkman" ]; then
        log "Installing SDKMAN..."
        curl -s "https://get.sdkman.io" | bash
        success "SDKMAN installed"
    else
        success "SDKMAN already installed"
    fi
}

install_yay() {
    if [ "$(detect_os)" = "arch" ] && ! command_exists yay; then
        log "Installing YAY AUR helper..."
        sudo pacman -S --needed base-devel git
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay
        makepkg -si --noconfirm
        cd -
        rm -rf /tmp/yay
        success "YAY installed"
    fi
}

install_opencode() {
    if ! command_exists opencode; then
        log "Installing OpenCode..."
        if [ ! -d "$HOME/.opencode" ]; then
            git clone https://github.com/anomalyco/opencode.git ~/.opencode
            cd ~/.opencode
            npm install
            npm run build
            npm link
            cd -
        fi
        success "OpenCode installed"
    else
        success "OpenCode already installed"
    fi
}