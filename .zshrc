# Aliases
alias ls='eza -T -L 1 --group-directories-first --links --smart-group --changed --icons'
alias vim='nvim'
alias neovim='nvim'
alias c='clear'
alias lzd='lazydocker'
alias lzg='lazygit'
alias run='cd $HOME/PGA && source venv/bin/activate && python3 manage.py runserver'
alias python='python3'

# Path Exports

export PATH=$PATH:"/usr/local/go/bin"
export PATH="$PATH:$HOME/.fzf/bin"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/go/bin"
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
export NVM_DIR="$HOME/.nvm"
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="$HOME/.local/bin:$PATH"

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

source <(fzf --zsh)
eval "$(zoxide init zsh)"

# --- Tmux auto-start configuration ---

export MAIN_DIR="$HOME/PGA"
if [ -z "$TMUX" ]; then
  if [ -f "/etc/debian_version" ]; then
    # --- Sessão principal: desenvolvimento local ---
    if ! tmux has-session -t project 2>/dev/null; then
      tmux new-session -d -s project -c "$MAIN_DIR" -n editor
      tmux send-keys -t project:editor 'vim .' Enter

      tmux new-window -t project -n server -c "$MAIN_DIR"
      tmux send-keys -t project:server 'source venv/bin/activate && python3 manage.py runserver' Enter

      tmux new-window -t project -n docker -c "$MAIN_DIR"
      tmux send-keys -t project:docker 'lazydocker' Enter
    fi

    # --- Sessão remota: servidor via SSH ---
    if ! tmux has-session -t remote 2>/dev/null; then
      tmux new-session -d -s remote -n ssh -c "$HOME"
      tmux send-keys -t remote:ssh 'ssh devint@192.168.41.229 -X' Enter
    fi

    # --- Conecta na sessão principal ---
    tmux attach -t project
  else
    # fallback genérico (não-debian)
    tmux new-session -A -s main
  fi
fi


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

