# Aliases
alias ls='eza -T -L 1 --group-directories-first --links --smart-group --changed --icons'
alias vim='nvim'
alias neovim='nvim'
alias c='clear'
alias lzd='lazydocker'
alias lzg='lazygit'

# Path Exports

export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:"/mnt/c/Users/heito/AppData/Local/Programs/Microsoft VS Code/bin"
export PATH="$PATH:/opt/nvim-linux64/bin"
export PATH="$PATH:/home/heitor/.fzf/bin"
export PATH="$PATH:/home/heitor/.local/bin"
export NVM_DIR="$HOME/.nvm"
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'


# Shell integrations

eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"

#Tmux conf
## Open Tmux when opening ZSH
if [ -z "$TMUX" ]; then
  if [ -f "/etc/debian_version" ]; then
    tmux new-session -A -s back -c /home/heitor/backend-orcamento-nestjs -n "editor" \; \
      send-keys 'vim .' Enter \; \
      new-window -n "server" -c /home/heitor/backend-orcamento-nestjs \; \
      send-keys 'yarn docker:up' Enter \; \
      send-keys 'yarn start:dev' Enter \; \
      select-window -t 1
    # Create frontend session if it doesn't exist
    tmux new-session -d -s front -c /home/heitor/frontend-orcamento-react -n "editor" \; \
      send-keys 'vim .' Enter \; \
      new-window -n "server" -c /home/heitor/frontend-orcamento-react \; \
      send-keys 'git pull' Enter \; \
      send-keys 'nvm use 18' Enter \; \
      send-keys 'yarn' Enter \; \
      send-keys 'yarn start' Enter \; \
      select-window -t 1
  else
    tmux new-session -A -s main
  fi
fi

eval $(thefuck --alias)

. "/home/heitor/.deno/env"

# Node Versioner Manager
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

if [ -e /home/heitor/.nix-profile/etc/profile.d/nix.sh ]; then . /home/heitor/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

# bun completions
[ -s "/home/heitor/.bun/_bun" ] && source "/home/heitor/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
