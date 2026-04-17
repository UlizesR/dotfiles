#!/usr/bin/env bash
# setup.sh — bootstrap a dev environment from this dotfiles repo
set -euo pipefail

# ── Helpers ───────────────────────────────────────────────────────────────────
info()    { echo "  $*"; }
success() { echo "  ✅ $*"; }
warn()    { echo "  ⚠️  $*"; }
step()    { echo ""; echo "── $* ──────────────────────────────────────────────"; }

# Symlink with automatic timestamped backup
link_with_backup() {
  local src="$1" dest="$2"
  if [[ -e "$dest" || -L "$dest" ]]; then
    mv "$dest" "${dest}.backup.$(date +%s)"
    info "Backed up existing $dest"
  fi
  ln -sfn "$src" "$dest"
  success "Linked: $src → $dest"
}

# Install a package only if the command is missing
install_if_missing() {
  local cmd="$1"; shift
  if command -v "$cmd" &>/dev/null; then
    success "$cmd already installed"
    return 0
  fi
  info "Installing $cmd…"
  "$@"
}

# Check whether a font family is installed (cross-platform)
font_installed() {
  local pattern="$1"
  if command -v fc-list &>/dev/null; then
    fc-list | grep -qi "$pattern"
  elif [[ "$(uname -s)" == "Darwin" ]]; then
    # Fallback for macOS without fontconfig
    find ~/Library/Fonts /Library/Fonts /System/Library/Fonts \
         -iname "*${pattern}*" 2>/dev/null | grep -q .
  else
    return 1
  fi
}

# ── OS / distro detection ─────────────────────────────────────────────────────
OS="$(uname -s)"   # Darwin | Linux
DISTRO="unknown"
if [[ "$OS" == "Linux" ]]; then
  if [[ -f /etc/os-release ]]; then
    DISTRO="$(. /etc/os-release && echo "${ID}")"
  elif [[ -f /etc/arch-release ]]; then
    DISTRO="arch"
  fi
fi

echo "🚀 Starting development environment setup…"
echo "   OS: $OS  |  Distro: $DISTRO"

# ── Self-update ───────────────────────────────────────────────────────────────
step "Updating dotfiles repo"
if [[ -d .git ]]; then
  git pull --ff-only
  success "Repo updated"
else
  warn "Not in a git repo — skipping pull"
fi

# ── Sync system clock (VMs / WSL) ─────────────────────────────────────────────
if [[ "$OS" == "Linux" ]] && command -v timedatectl &>/dev/null; then
  step "Syncing system time"
  if ! timedatectl status 2>/dev/null | grep -q "NTP synchronized: yes"; then
    sudo timedatectl set-ntp true 2>/dev/null || true
    sleep 2
  fi
  success "System time OK"
fi

# ── zsh ───────────────────────────────────────────────────────────────────────
step "Ensuring zsh is installed"
if ! command -v zsh &>/dev/null; then
  if [[ "$OS" == "Darwin" ]]; then
    brew install zsh
  elif [[ "$DISTRO" == "arch" ]]; then
    sudo pacman -S --noconfirm zsh
  else
    sudo apt-get install -y zsh
  fi
fi
success "zsh: $(zsh --version)"

# ── macOS-specific tooling ────────────────────────────────────────────────────
if [[ "$OS" == "Darwin" ]]; then
  step "macOS setup"

  # Xcode Command Line Tools
  if ! xcode-select -p &>/dev/null; then
    warn "Xcode CLT missing. Installing — re-run this script after the dialog completes."
    xcode-select --install
    exit 1
  fi
  success "Xcode CLT present"

  # Homebrew
  if ! command -v brew &>/dev/null; then
    info "Installing Homebrew…"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  # Source brew into this session
  for _b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x "$_b" ]] && eval "$($_b shellenv)" && break
  done
  success "Homebrew: $(brew --version | head -1)"

  brew update
  brew upgrade

  # CLI tools
  step "CLI tools (Homebrew)"
  for pkg in neovim fzf ripgrep bat zoxide tmux htop git; do
    if brew list --formula "$pkg" &>/dev/null; then
      success "$pkg already installed"
    else
      info "Installing $pkg…"; brew install "$pkg"; success "$pkg installed"
    fi
  done

  # starship
  install_if_missing starship \
    bash -c "$(curl -sS https://starship.rs/install.sh) -- --yes"

  # pyenv
  install_if_missing pyenv brew install pyenv

  # nvm
  if [[ ! -d "$HOME/.nvm" ]]; then
    info "Installing nvm…"
    brew install nvm
    mkdir -p "$HOME/.nvm"
  fi
  success "nvm ready"

  # JetBrains Mono Nerd Font
  step "Fonts"
  if font_installed "JetBrainsMono"; then
    success "JetBrains Mono Nerd Font already installed"
  else
    info "Installing JetBrains Mono Nerd Font…"
    brew install --cask font-jetbrains-mono-nerd-font
    success "Font installed"
  fi

  # WezTerm
  step "WezTerm"
  if ! command -v wezterm &>/dev/null; then
    info "Installing WezTerm…"
    brew install --cask wezterm
    success "WezTerm installed"
  else
    success "WezTerm already installed"
  fi

  # macOS defaults
  step "macOS defaults"
  defaults write com.apple.finder AppleShowAllFiles -bool true
  killall Finder 2>/dev/null || true
  success "Finder shows hidden files"

# ── Linux-specific tooling ────────────────────────────────────────────────────
else
  step "Linux setup ($DISTRO)"

  if [[ "$DISTRO" == "arch" ]]; then
    # ── Arch Linux ────────────────────────────────────────────────────────────
    sudo pacman -Sy --noconfirm

    PKGS_NEEDED=()
    for pkg in neovim fzf ripgrep bat tmux htop git curl wget unzip; do
      pacman -Qi "$pkg" &>/dev/null && success "$pkg installed" || PKGS_NEEDED+=("$pkg")
    done
    [[ ${#PKGS_NEEDED[@]} -gt 0 ]] && sudo pacman -S --noconfirm "${PKGS_NEEDED[@]}"

    install_if_missing zoxide \
      bash -c "$(curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh)"

    # WezTerm
    if ! command -v wezterm &>/dev/null; then
      info "Installing WezTerm (pacman)…"
      sudo pacman -S --noconfirm wezterm
      success "WezTerm installed"
    else
      success "WezTerm already installed"
    fi

    # Nerd Font symbols
    if ! pacman -Qi ttf-nerd-fonts-symbols-mono &>/dev/null; then
      sudo pacman -S --noconfirm ttf-nerd-fonts-symbols-mono
    fi
    success "Nerd Font symbols present"

    # JetBrains Mono Nerd Font
    step "Fonts"
    if font_installed "JetBrainsMono"; then
      success "JetBrains Mono Nerd Font already installed"
    else
      info "Installing JetBrains Mono Nerd Font…"
      if command -v yay &>/dev/null; then
        yay -S --noconfirm ttf-jetbrains-mono-nerd
      elif command -v paru &>/dev/null; then
        paru -S --noconfirm ttf-jetbrains-mono-nerd
      else
        mkdir -p ~/.local/share/fonts
        curl -Lo ~/.local/share/fonts/JetBrainsMono.zip \
          https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
        unzip -o ~/.local/share/fonts/JetBrainsMono.zip \
              -d ~/.local/share/fonts/JetBrainsMono/
        fc-cache -fv
      fi
      success "JetBrains Mono Nerd Font installed"
    fi

  elif command -v apt-get &>/dev/null; then
    # ── Debian / Ubuntu ───────────────────────────────────────────────────────
    sudo apt-get update -qq

    PKGS_NEEDED=()
    for pkg in neovim fzf ripgrep bat tmux htop git curl wget unzip; do
      dpkg -s "$pkg" &>/dev/null && success "$pkg installed" || PKGS_NEEDED+=("$pkg")
    done
    [[ ${#PKGS_NEEDED[@]} -gt 0 ]] && sudo apt-get install -y "${PKGS_NEEDED[@]}"

    install_if_missing zoxide \
      bash -c "$(curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh)"

    # WezTerm via its APT repo
    if ! command -v wezterm &>/dev/null; then
      info "Installing WezTerm (apt)…"
      curl -fsSL https://apt.fury.io/wez/gpg.key \
        | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
      echo "deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *" \
        | sudo tee /etc/apt/sources.list.d/wezterm.list >/dev/null
      sudo apt-get update -qq
      sudo apt-get install -y wezterm
      success "WezTerm installed"
    else
      success "WezTerm already installed"
    fi

    # JetBrains Mono Nerd Font
    step "Fonts"
    if font_installed "JetBrainsMono"; then
      success "JetBrains Mono Nerd Font already installed"
    else
      info "Installing JetBrains Mono Nerd Font…"
      mkdir -p ~/.local/share/fonts
      curl -Lo ~/.local/share/fonts/JetBrainsMono.zip \
        https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
      unzip -o ~/.local/share/fonts/JetBrainsMono.zip \
            -d ~/.local/share/fonts/JetBrainsMono/
      fc-cache -fv
      success "JetBrains Mono Nerd Font installed"
    fi

  else
    warn "Unsupported distro ($DISTRO) — install CLI tools manually."
  fi

  # ── Shared Linux: starship, pyenv, nvm ────────────────────────────────────
  step "Cross-distro tools"

  install_if_missing starship \
    sh -c "$(curl -sS https://starship.rs/install.sh) -- --yes"

  if [[ ! -d "$HOME/.pyenv" ]]; then
    info "Installing pyenv…"
    curl https://pyenv.run | bash
    success "pyenv installed"
  else
    success "pyenv already installed"
  fi

  if [[ ! -d "$HOME/.nvm" ]]; then
    info "Installing nvm…"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    success "nvm installed"
  else
    success "nvm already installed"
  fi
fi  # end Linux

# ── Python: make the active python3 the system default ───────────────────────
step "Python default"
# If `python` doesn't exist but `python3` does, create a user-local symlink
# so tools that call `python` work without modifying system paths.
if ! command -v python &>/dev/null && command -v python3 &>/dev/null; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(command -v python3)" "$HOME/.local/bin/python"
  ln -sf "$(command -v pip3)"    "$HOME/.local/bin/pip" 2>/dev/null || true
  success "Linked python3 → ~/.local/bin/python"
else
  success "python command already available"
fi
info "Python: $(python3 --version 2>/dev/null || echo 'not found')"

# ── zinit ─────────────────────────────────────────────────────────────────────
step "zinit"
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
  success "zinit installed"
else
  success "zinit already installed"
fi

# ── Symlink dotfiles ──────────────────────────────────────────────────────────
step "Symlinking dotfiles"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$HOME/.config"

link_with_backup "${REPO_DIR}/nvim"                  "$HOME/.config/nvim"
link_with_backup "${REPO_DIR}/starship/starship.toml" "$HOME/.config/starship.toml"
link_with_backup "${REPO_DIR}/wezterm"               "$HOME/.config/wezterm"
link_with_backup "${REPO_DIR}/zshrc/.zshrc"          "$HOME/.zshrc"

# ── Default shell ─────────────────────────────────────────────────────────────
step "Default shell"
ZSH_PATH="$(command -v zsh)"
if grep -qF "$ZSH_PATH" /etc/shells 2>/dev/null; then
  if [[ "$SHELL" != "$ZSH_PATH" ]]; then
    chsh -s "$ZSH_PATH"
    success "Default shell set to $ZSH_PATH (re-login to apply)"
  else
    success "zsh is already the default shell"
  fi
else
  warn "$ZSH_PATH is not in /etc/shells — run: echo '$ZSH_PATH' | sudo tee -a /etc/shells"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "🎉 Setup complete!"
echo ""
echo "📋 Next steps:"
echo "   • Set your terminal font to 'JetBrains Mono Nerd Font'"
echo "   • source ~/.zshrc  (or open a new terminal)"
echo "   • Open nvim — Lazy will auto-install plugins on first launch"
echo "   • Press ${mod:-CTRL}+? in WezTerm to view all keybindings"
echo "   • Press <leader>fk in nvim to browse all keymaps"
echo ""
