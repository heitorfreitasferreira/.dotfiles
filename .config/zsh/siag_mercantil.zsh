#!/bin/zsh

export MAIN_DIR="$HOME/siag"
export ERP_DIR="$MAIN_DIR/agromercantil-erp/erp"
export ERP_HTML_DIR="$MAIN_DIR/agromercantil-erp/erp-html"

if [ -z "$TMUX" ]; then
  if [ -f "/etc/debian_version" ]; then
    # --- Sessão SIAG ---
    if ! tmux has-session -t siag 2>/dev/null; then
      tmux new-session -d -s siag -c "$MAIN_DIR" -n EDITOR
      tmux send-keys -t siag:EDITOR 'nvim' Enter
    fi

    if ! tmux list-windows -t siag -F '#{window_name}' 2>/dev/null | grep -qx 'APPS'; then
      tmux new-window -t siag -n APPS -c "$ERP_DIR"
      tmux send-keys -t siag:APPS 'mvn spring-boot:run' Enter
      tmux split-window -h -t siag:APPS -c "$ERP_HTML_DIR"
      tmux send-keys -t siag:APPS.2 'gulp dev' Enter
      tmux select-pane -t siag:APPS.1
    fi

    # --- Conecta na sessão SIAG ---
    tmux attach -t siag
  else
    # fallback genérico (não-debian)
    tmux new-session -A -s siag -c "$MAIN_DIR"
  fi
fi
