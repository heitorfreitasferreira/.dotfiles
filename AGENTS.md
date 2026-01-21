# AGENTS.md - Development Guidelines for This Repository

This document contains essential information for agentic coding assistants working in this dotfiles repository.

## Repository Overview

This is a personal dotfiles repository managed with GNU Stow, containing configurations for development tools. The repository is primarily in Portuguese but uses English for technical configurations.

## Build/Test/Lint Commands

### Shell Scripts
- **Installation scripts**: `./scripts/arch.sh`, `./scripts/debian.sh`
- **Custom script**: `./scripts/frete_mercantil.sh` (executed from .zshrc)

### Neovim (Primary Editor)
- **Format**: Use `:Format` (conform.nvim) or auto-format on save
- **Lint**: Automatic via nvim-lint
- **LSP**: `:LspInfo` to check status
- **Stylua**: `stylua .` for Lua files (uses .config/nvim/stylua.toml)

### Package Management
- **Node.js**: npm commands work in .config/opencode/ and .config/nvim/snippets/
- **AUR**: `yay` for Arch Linux packages
- **Stow**: `stow .` to symlink configurations

## Code Style Guidelines

### General Files
- **Indentation**: 4 spaces (vim.opt.tabstop = 4, expandtab = true)
- **Line wrapping**: Enabled
- **File encoding**: UTF-8

### Lua Files
- **Indentation**: 2 spaces (per stylua.toml)
- **Line width**: 120 characters
- **Formatting**: Use stylua

### Shell Scripts
- **Shebang**: `#!/bin/bash`
- **Error handling**: Use `set -e` for critical scripts
- **Quoting**: Double quotes for variables with spaces

### Configuration Files
- **Structure**: Modular approach (see .config/zsh/ structure)
- **Sourcing**: Use absolute paths from $HOME/.dotfiles
- **Comments**: Portuguese for user-facing docs, English for technical

## Import/Module Conventions

### Shell/Zsh
- Source modular configs: `source ~/.dotfiles/.config/zsh/module.zsh`
- Use absolute paths for reliability
- Load order matters (paths first, then plugins, then aliases)

### Lua/Neovim
- Use `require("config.module")` pattern
- Follow LazyVim conventions
- Separate concerns into different files under lua/config/

### Node.js
- Use npm for package management
- Follow semver for dependencies

## Naming Conventions

### Files
- **Config files**: `.filename` for dotfiles
- **Scripts**: `lowercase.sh` for shell scripts
- **Lua modules**: `module.lua` under appropriate directories

### Variables/Functions
- **Shell**: `snake_case` for variables, `function_name()` for functions
- **Lua**: `snake_case` for variables/functions, `PascalCase` for modules
- **Aliases**: Short, mnemonic (e.g., `ls`, `vim`, `c`)

## Error Handling

### Shell Scripts
- Use `set -e` to exit on errors
- Check command existence with `command -v`
- Provide meaningful error messages

### Configuration
- Test for file existence before sourcing
- Use conditional loading for optional features
- Handle different OS/distro cases

## Development Tools Integration

### Neovim Plugins (LazyVim based)
- **Code completion**: Built-in LSP + Copilot/Sidekick AI
- **Formatting**: conform.nvim (auto-format on save)
- **Linting**: nvim-lint (asynchronous)
- **Git**: Gitsigns integration
- **File navigation**: Neo-tree, Harpoon

### Shell Enhancements
- **Zinit**: Plugin manager for Zsh
- **Powerlevel10k**: Customizable prompt
- **fzf**: Fuzzy finding
- **zoxide**: Smart directory navigation

## Testing

### Configuration Testing
- **Shell**: Test scripts with `bash -n` for syntax
- **Zsh**: Load new config with `source ~/.zshrc`
- **Neovim**: Check health with `:checkhealth`

### Installation Testing
- Test scripts in clean environment
- Verify symlinks created correctly
- Check all tools load without errors

## Repository-Specific Rules

### Stow Management
- Use `.stow-local-ignore` to exclude files
- Keep structure mirrored to home directory
- Test symlinks after stow operations

### Git Configuration
- Use SSH keys for GitHub (see README.md)
- Commit configuration changes, not runtime files
- Exclude sensitive data via .gitignore

### Cross-Platform Considerations
- Handle macOS (Homebrew) vs Linux differences
- Use conditional paths and package managers
- Test on target systems before committing

## Common Patterns

### Modular Configuration
```bash
# .zshrc structure
source ~/.dotfiles/.config/zsh/paths.zsh
source ~/.dotfiles/.config/zsh/aliases.zsh
source ~/.dotfiles/.config/zsh/plugins.zsh
```

### Neovim Configuration
```lua
-- lua/config/options.lua
vim.opt.tabstop = 4
vim.opt.expandtab = true
```

### Installation Script Pattern
```bash
#!/bin/bash
# Update system
sudo pacman -Syu
# Install packages
sudo pacman -S package1 package2
# Configure
stow .
```

## Notes for Agents

1. **Language**: Repository metadata is in Portuguese, but code comments should be in English
2. **Primary Tools**: Neovim + LazyVim, Zsh + Zinit, GNU Stow
3. **Target Systems**: Arch Linux (primary), Debian, macOS (secondary)
4. **Automation**: This repo is designed for automated setup and configuration
5. **Testing**: Always test configuration changes before committing

When making changes, ensure compatibility across the supported systems and follow the existing modular structure.