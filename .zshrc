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

# Source modular configurations
source ~/.dotfiles/.config/zsh/paths.zsh
source ~/.dotfiles/.config/zsh/aliases.zsh
source ~/.dotfiles/.config/zsh/plugins.zsh
source ~/.dotfiles/.config/zsh/history.zsh
source ~/.dotfiles/.config/zsh/completion.zsh
source ~/.dotfiles/.config/zsh/integrations.zsh
source ~/.dotfiles/.config/zsh/keybindings.zsh

source ~/.dotfiles/scripts/frete_mercantil.zsh

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
