#!/bin/zsh

export MAIN_DIR="$HOME/FRETE-E-API/"
if [ -z "$TMUX" ]; then
  if [ -f "/etc/debian_version" ]; then
    # --- Sessão principal: desenvolvimento local ---
    if ! tmux has-session -t project 2>/dev/null; then
      tmux new-session -d -s project -c "$MAIN_DIR" -n editor
      tmux send-keys -t project:editor 'vim' Enter
      tmux send-keys -t project:editor ':1wincmd w' Enter

      tmux new-window -t project -n server -c "$MAIN_DIR"
      tmux send-keys -t project:server 'docker compose --profile dev up -d && lzd' Enter
    fi

    # --- Sessão remota: servidor via SSH ---
    if ! tmux has-session -t remote 2>/dev/null; then
      tmux new-session -d -s remote -n ssh -c "$HOME"
      tmux send-keys -t remote:ssh 'ssh devint@192.168.41.229 -X' Enter
    fi

    # --- Conecta na sessão principal ---
    tmux attach -t project
    # --- Seleciona a primeira janela ---
  else
    # fallback genérico (não-debian)
    tmux new-session -A -s main
  fi
fi
