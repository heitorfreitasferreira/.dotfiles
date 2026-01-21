#!/bin/bash

# Login shell configuration

change_default_shell() {
    log "Changing default shell to Zsh..."
    
    if [ "$SHELL" != "$(which zsh)" ]; then
        chsh -s "$(which zsh)"
        success "Default shell changed to Zsh"
    else
        success "Zsh is already the default shell"
    fi
}

setup_powerlevel10k() {
    log "Setting up Powerlevel10k prompt..."
    
    # P10k will be installed via Zinit as configured in plugins.zsh
    if [ ! -f "$HOME/.p10k.zsh" ]; then
        log "Run 'p10k configure' after first login to customize prompt"
        success "Powerlevel10k will be configured on first use"
    else
        success "Powerlevel10k already configured"
    fi
}

setup_nvm() {
    log "Setting up Node Version Manager..."
    
    if [ -d "$HOME/.nvm" ]; then
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        success "NVM configured"
    fi
}

setup_sdkman() {
    log "Setting up SDKMAN..."
    
    if [ -d "$HOME/.sdkman" ]; then
        export SDKMAN_DIR="$HOME/.sdkman"
        [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
        success "SDKMAN configured"
    fi
}

configure_environment_variables() {
    log "Configuring environment variables..."
    
    # Add Go to PATH
    if command_exists go; then
        export PATH="$PATH:$(go env GOPATH)/bin"
    fi
    
    # Add local bin to PATH
    export PATH="$PATH:$HOME/.local/bin"
    
    # Set locale
    export LANG=en_US.UTF-8
    export LC_CTYPE=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    
    success "Environment variables configured"
}

setup_shell_completions() {
    log "Setting up shell completions..."
    
    # Zsh completions will be handled by Zinit
    # Additional completions can be added here
    success "Shell completions configured"
}