#!/bin/zsh

export MAIN_DIR="$HOME/agromercantil/"
if [ -z "$TMUX" ]; then
  if [ -f "/etc/debian_version" ]; then
    # --- Sessão principal: pasta com todos projetos ---
    if ! tmux has-session -t projects 2>/dev/null; then
      tmux new-session -d -s projects -c "$MAIN_DIR" -n opencode
      tmux send-keys -t projects:opencode 'opencode' Enter
    fi

    if ! tmux list-windows -t projects -F '#{window_name}' 2>/dev/null | grep -qx 'vim'; then
      tmux new-window -t projects -n vim -c "$MAIN_DIR"
      tmux send-keys -t projects:vim 'vim' Enter
    fi
    # --- Sessão remota: servidor via SSH ---
    if ! tmux has-session -t remotes 2>/dev/null; then
      tmux new-session -d -s remotes -n ssh -c "$HOME"
      tmux send-keys -t remotes:ssh 'ssh -t devint-229 "tmux new -A -s heitor"' Enter
    fi

    if ! tmux list-windows -t remotes -F '#{window_name}' 2>/dev/null | grep -qx 'ssh-2424'; then
      tmux new-window -t remotes -n ssh-2424 -c "$HOME"
      tmux send-keys -t remotes:ssh-2424 'ssh devint-218' Enter
    fi

    # --- Sessão backend ---
    if ! tmux has-session -t backend 2>/dev/null; then
      tmux new-session -d -s backend -n nvim -c "$MAIN_DIR/FRETE-E-API"
      tmux send-keys -t backend:nvim 'nvim' Enter
    fi

    if ! tmux list-windows -t backend -F '#{window_name}' 2>/dev/null | grep -qx 'run'; then
      tmux new-window -t backend -n run -c "$MAIN_DIR/FRETE-E-API"
      tmux send-keys -t backend:run 'back' Enter
    fi

    # --- Sessão frontend ---
    if ! tmux has-session -t frontend 2>/dev/null; then
      tmux new-session -d -s frontend -n nvim -c "$MAIN_DIR/FRETE-E-FED"
      tmux send-keys -t frontend:nvim 'nvim' Enter
    fi

    if ! tmux list-windows -t frontend -F '#{window_name}' 2>/dev/null | grep -qx 'run'; then
      tmux new-window -t frontend -n run -c "$MAIN_DIR/FRETE-E-FED"
      tmux send-keys -t frontend:run 'front' Enter
    fi

    # --- Conecta na sessão principal ---
    tmux attach -t projects
    # --- Seleciona a primeira janela ---
  else
    # fallback genérico (não-debian)
    tmux new-session -A -s main
  fi
fi
