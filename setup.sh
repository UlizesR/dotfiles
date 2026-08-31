#!/usr/bin/env bash
# setup.sh — bootstrap a dev environment from this dotfiles repo
set -euo pipefail

# ── Config ─────────────────────────────────────────────────────────────────
NERD_FONT_VERSION="v3.1.1"

# ── Helpers ──────────────────────────────────────────────────────────────────
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

# Generic "install X if a check fails" helper.
# Usage: install_if_missing "<check expr>" "<display name>" <install cmd...>
install_if_missing() {
  local check="$1" desc="$2"; shift 2
  if eval "$check" &>/dev/null; then
    success "$desc already installed"
    return 0
  fi
  info "Installing $desc…"
  "$@"
  success "$desc installed"
}

# Check whether a font family is installed (cross-platform)
font_installed() {
  local pattern="$1"
  if command -v fc-list &>/dev/null; then
    fc-list | grep -qi "$pattern"
  elif [[ "$(uname -s)" == "Darwin" ]]; then
    find ~/Library/Fonts /Library/Fonts /System/Library/Fonts \
         -iname "*${pattern}*" 2>/dev/null | grep -q .
  else
    return 1
  fi
}

# Download + unpack the Nerd Font manually (used when no package/cask exists)
install_nerd_font_manual() {
  mkdir -p ~/.local/share/fonts
  curl -Lo ~/.local/share/fonts/JetBrainsMono.zip \
    "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONT_VERSION}/JetBrainsMono.zip"
  unzip -o ~/.local/share/fonts/JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono/
  fc-cache -fv
}

install_wezterm_apt() {
  curl -fsSL https://apt.fury.io/wez/gpg.key \
    | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
  echo "deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *" \
    | sudo tee /etc/apt/sources.list.d/wezterm.list >/dev/null
  sudo apt-get update -qq
  sudo apt-get install -y wezterm
}

# Batch-install only the missing packages from a list (apt)
apt_ensure() {
  local needed=()
  for pkg in "$@"; do
    dpkg -s "$pkg" &>/dev/null && success "$pkg installed" || needed+=("$pkg")
  done
  ((${#needed[@]})) && sudo apt-get install -y "${needed[@]}"
  return 0
}

# Batch-install only the missing packages from a list (pacman)
pacman_ensure() {
  local needed=()
  for pkg in "$@"; do
    pacman -Qi "$pkg" &>/dev/null && success "$pkg installed" || needed+=("$pkg")
  done
  ((${#needed[@]})) && sudo pacman -S --noconfirm "${needed[@]}"
  return 0
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
    install_if_missing "brew list --formula $pkg" "$pkg" brew install "$pkg"
  done

  install_if_missing "command -v starship" "starship" \
    bash -c "$(curl -sS https://starship.rs/install.sh) -- --yes"

  install_if_missing "command -v pyenv" "pyenv" brew install pyenv

  install_if_missing "[[ -d \$HOME/.nvm ]]" "nvm" \
    bash -c "brew install nvm && mkdir -p \$HOME/.nvm"

  step "Fonts"
  install_if_missing "font_installed JetBrainsMono" "JetBrains Mono Nerd Font" \
    brew install --cask font-jetbrains-mono-nerd-font

  step "WezTerm"
  install_if_missing "command -v wezterm" "WezTerm" brew install --cask wezterm

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
    pacman_ensure neovim fzf ripgrep bat tmux htop git curl wget unzip

    install_if_missing "command -v zoxide" "zoxide" \
      bash -c "$(curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh)"

    step "WezTerm"
    install_if_missing "command -v wezterm" "WezTerm" sudo pacman -S --noconfirm wezterm

    install_if_missing "pacman -Qi ttf-nerd-fonts-symbols-mono" "Nerd Font symbols" \
      sudo pacman -S --noconfirm ttf-nerd-fonts-symbols-mono

    step "Fonts"
    if font_installed "JetBrainsMono"; then
      success "JetBrains Mono Nerd Font already installed"
    elif command -v yay &>/dev/null; then
      info "Installing JetBrains Mono Nerd Font (yay)…"
      yay -S --noconfirm ttf-jetbrains-mono-nerd
      success "JetBrains Mono Nerd Font installed"
    elif command -v paru &>/dev/null; then
      info "Installing JetBrains Mono Nerd Font (paru)…"
      paru -S --noconfirm ttf-jetbrains-mono-nerd
      success "JetBrains Mono Nerd Font installed"
    else
      info "Installing JetBrains Mono Nerd Font (manual)…"
      install_nerd_font_manual
      success "JetBrains Mono Nerd Font installed"
    fi

  elif command -v apt-get &>/dev/null; then
    # ── Debian / Ubuntu ───────────────────────────────────────────────────────
    sudo apt-get update -qq
    apt_ensure neovim fzf ripgrep bat tmux htop git curl wget unzip

    install_if_missing "command -v zoxide" "zoxide" \
      bash -c "$(curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh)"

    step "WezTerm"
    install_if_missing "command -v wezterm" "WezTerm" install_wezterm_apt

    step "Fonts"
    install_if_missing "font_installed JetBrainsMono" "JetBrains Mono Nerd Font" \
      install_nerd_font_manual

  else
    warn "Unsupported distro ($DISTRO) — install CLI tools manually."
  fi

  # ── Shared Linux: starship, pyenv, nvm ────────────────────────────────────
  step "Cross-distro tools"

  install_if_missing "command -v starship" "starship" \
    sh -c "$(curl -sS https://starship.rs/install.sh) -- --yes"

  install_if_missing "[[ -d \$HOME/.pyenv ]]" "pyenv" \
    bash -c "curl https://pyenv.run | bash"

  install_if_missing "[[ -d \$HOME/.nvm ]]" "nvm" \
    bash -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
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
install_if_missing "[[ -d $ZINIT_HOME ]]" "zinit" \
  bash -c "mkdir -p \"\$(dirname \"$ZINIT_HOME\")\" && git clone https://github.com/zdharma-continuum/zinit.git \"$ZINIT_HOME\""

# ── Symlink dotfiles ──────────────────────────────────────────────────────────
step "Symlinking dotfiles"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$HOME/.config"

link_with_backup "${REPO_DIR}/nvim"                   "$HOME/.config/nvim"
link_with_backup "${REPO_DIR}/starship/starship.toml" "$HOME/.config/starship.toml"
link_with_backup "${REPO_DIR}/wezterm"                "$HOME/.config/wezterm"
link_with_backup "${REPO_DIR}/zshrc/.zshrc"           "$HOME/.zshrc"

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
echo "   • Check your WezTerm config for the keybindings cheat-sheet"
echo "   • Press <leader>fk in nvim to browse all keymaps"
echo ""
