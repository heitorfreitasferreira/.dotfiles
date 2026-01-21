#!/bin/bash

# Helper functions used throughout the setup process

# Retry mechanism for network operations
retry() {
  local retries=$1
  shift
  local count=0

  until "$@"; do
    exit_code=$?
    count=$((count + 1))
    if [ $count -lt $retries ]; then
      echo "Retry $count/$retries exited $exit_code, retrying..."
      sleep 2
    else
      error "Command failed after $retries attempts"
    fi
  done
}

# Progress indicator
show_progress() {
  local current=$1
  local total=$2
  local desc=$3

  local percent=$((current * 100 / total))
  local filled=$((percent / 2))
  local empty=$((50 - filled))

  printf "\r%s: [" "$desc"
  printf "%*s" $filled | tr ' ' '='
  printf "%*s" $empty | tr ' ' '-'
  printf "] %d%% (%d/%d)" $percent $current $total
}

# Wait for user input with timeout
wait_for_user() {
  local timeout=${1:-10}
  local message=${2:-"Press any key to continue..."}

  echo -n "$message (timeout: ${timeout}s) "
  read -t $timeout -n 1 || echo " (timeout)"
}

# Check if package is available
package_available() {
  local package=$1
  local os=$(detect_os)

  case $os in
  arch)
    pacman -Si "$package" >/dev/null 2>&1 || yay -Si "$package" >/dev/null 2>&1
    ;;
  debian)
    apt-cache show "$package" >/dev/null 2>&1 || nix-env -qa "$package" >/dev/null 2>&1
    ;;
  macos)
    brew info "$package" >/dev/null 2>&1
    ;;
  esac
}

# Create backup with timestamp
backup_with_timestamp() {
  local source=$1
  local backup_dir=${2:-"$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"}

  if [ -e "$source" ]; then
    mkdir -p "$backup_dir"
    cp -r "$source" "$backup_dir/"
    echo "Backed up $source to $backup_dir"
  fi
}

# Verify checksum
verify_checksum() {
  local file=$1
  local expected=$2

  if command_exists sha256sum; then
    local actual=$(sha256sum "$file" | cut -d' ' -f1)
    [ "$actual" = "$expected" ]
  elif command_exists shasum; then
    local actual=$(shasum -a 256 "$file" | cut -d' ' -f1)
    [ "$actual" = "$expected" ]
  else
    warning "Checksum verification not available"
    return 0
  fi
}

# Safe symlink creation
safe_symlink() {
  local source=$1
  local target=$2

  if [ -L "$target" ]; then
    log "Removing existing symlink: $target"
    rm "$target"
  elif [ -e "$target" ]; then
    backup_with_timestamp "$target"
    rm -rf "$target"
  fi

  ln -s "$source" "$target"
  success "Created symlink: $target -> $source"
}

# Get latest GitHub release URL
get_latest_release() {
  local repo=$1
  local filter=${2:-".tar.gz"}

  curl -s "https://api.github.com/repos/$repo/releases/latest" |
    grep "browser_download_url.*$filter" |
    cut -d '"' -f 4
}

# Download and extract archive
download_and_extract() {
  local url=$1
  local destination=$2
  local archive_name=$(basename "$url")

  log "Downloading $archive_name..."
  curl -L "$url" -o "/tmp/$archive_name"

  log "Extracting to $destination..."
  mkdir -p "$destination"

  case "$archive_name" in
  *.tar.gz | *.tgz)
    tar -xzf "/tmp/$archive_name" -C "$destination" --strip-components=1
    ;;
  *.tar.bz2)
    tar -xjf "/tmp/$archive_name" -C "$destination" --strip-components=1
    ;;
  *.zip)
    unzip -q "/tmp/$archive_name" -d "$destination"
    ;;
  *)
    error "Unsupported archive format: $archive_name"
    ;;
  esac

  rm "/tmp/$archive_name"
  success "Extracted $archive_name"
}

# Add to PATH if not already present
add_to_path() {
  local new_path=$1
  local profile_file=${2:-"$HOME/.zshrc"}

  if ! echo "$PATH" | grep -q "$new_path"; then
    echo "export PATH=\"\$PATH:$new_path\"" >>"$profile_file"
    success "Added $new_path to PATH in $profile_file"
  fi
}

# Service management
manage_service() {
  local action=$1
  local service=$2

  case $(detect_os) in
  arch | debian)
    if command_exists systemctl; then
      sudo systemctl "$action" "$service"
    fi
    ;;
  macos)
    if command_exists brew; then
      brew services "$action" "$service"
    fi
    ;;
  esac
}

