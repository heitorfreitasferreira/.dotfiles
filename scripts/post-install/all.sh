#!/bin/bash

# Post-installation tasks and verification

verify_installations() {
    log "Verifying installations..."
    
    local tools=("git" "zsh" "nvim" "tmux" "fzf" "zoxide" "eza" "wget" "go" "docker" "stow" "java")
    
    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            version=$($tool --version 2>/dev/null || $tool -v 2>/dev/null || echo "installed")
            success "$tool: $version"
        else
            warning "$tool: not found"
        fi
    done
}

run_first_time_configurations() {
    log "Running first-time configurations..."
    
    # Source Zsh configuration
    if [ -f "$HOME/.zshrc" ]; then
        zsh -c "source ~/.zshrc"
        success "Zsh configuration sourced"
    fi
    
    # Source Tmux configuration
    if [ -f "$HOME/.config/tmux/tmux.conf" ]; then
        tmux source-file ~/.config/tmux/tmux.conf 2>/dev/null || true
        success "Tmux configuration sourced"
    fi
}

install_node_lts() {
    log "Installing Node.js LTS..."
    
    if [ -d "$HOME/.nvm" ]; then
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
        if ! command_exists node; then
            nvm install --lts
            nvm use --lts
            nvm alias default lts/*
            success "Node.js LTS installed"
        else
            success "Node.js already installed"
        fi
    fi
}

setup_python_environment() {
    log "Setting up Python environment..."
    
    if command_exists python3; then
        # Install pip if not present
        if ! command_exists pip3; then
            python3 -m ensurepip --upgrade || sudo apt install python3-pip || true
        fi
        
        # Install basic Python packages
        pip3 install --user pipx virtualenv || true
        success "Python environment configured"
    fi
}

cleanup() {
    log "Cleaning up..."
    
    # Remove temporary files
    rm -rf /tmp/yay 2>/dev/null || true
    
    # Clear package manager cache
    case $(detect_os) in
        arch)
            if command_exists yay; then
                yay -Scc --noconfirm || true
            fi
            ;;
        debian)
            sudo apt autoremove -y || true
            ;;
        macos)
            brew cleanup || true
            ;;
    esac
    
    success "Cleanup completed"
}

display_completion_message() {
    echo ""
    echo "🎉 Development environment setup completed successfully!"
    echo ""
    echo "📋 Summary of installed tools:"
    echo "  • Git - Version control"
    echo "  • Zsh + Zinit + Powerlevel10k - Enhanced shell"
    echo "  • Neovim + LazyVim - Modern editor"
    echo "  • Tmux + TPM - Terminal multiplexer"
    echo "  • FZF - Fuzzy finder"
    echo "  • Zoxide - Smart directory navigation"
    echo "  • Eza - Modern ls replacement"
    echo "  • Docker - Containerization"
    echo "  • Go - Programming language"
    echo "  • Node.js (LTS) - JavaScript runtime"
    echo "  • Java - Programming language"
    echo "  • GNU Stow - Dotfile management"
    echo ""
    echo "🚀 Next steps:"
    echo "  1. Restart your shell or run: source ~/.zshrc"
    echo "  2. Configure Powerlevel10k: p10k configure"
    echo "  3. Install Tmux plugins: Press prefix + I in Tmux"
    echo "  4. Add your SSH key to GitHub: cat ~/.ssh/id_ed25519.pub"
    echo ""
    echo "📝 Custom aliases available:"
    echo "  • ls -> eza with custom options"
    echo "  • vim, neovim -> nvim"
    echo "  • lzd -> lazydocker"
    echo "  • lzg -> lazygit"
    echo "  • run -> Django development server"
    echo ""
    echo "Happy coding! 🎯"
}

create_post_install_log() {
    log "Creating installation log..."
    
    {
        echo "Development Environment Installation Log"
        echo "====================================="
        echo "Date: $(date)"
        echo "OS: $(uname -a)"
        echo "Shell: $SHELL"
        echo ""
        echo "Installed versions:"
        
        local tools=("git" "zsh" "nvim" "tmux" "fzf" "zoxide" "eza" "wget" "go" "docker" "stow" "java" "node")
        
        for tool in "${tools[@]}"; do
            if command_exists "$tool"; then
                echo "$tool: $($tool --version 2>/dev/null | head -n1 || $tool -v 2>/dev/null | head -n1 || echo 'installed')"
            fi
        done
        
        echo ""
        echo "Installation completed successfully!"
    } > "$HOME/.dev-setup-install.log"
    
    success "Installation log created at $HOME/.dev-setup-install.log"
}