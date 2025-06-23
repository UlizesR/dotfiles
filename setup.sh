#!/usr/bin/env bash
set -euo pipefail

# Helper function for symlinking with backup
link_with_backup() {
    local src="$1"
    local dest="$2"
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        mv "$dest" "${dest}.backup.$(date +%s)"
        echo "Backed up $dest"
    fi
    ln -sfn "$src" "$dest"
    echo "Linked $src -> $dest"
}

# Detect OS
OS=$(uname -s)

# Pull latest dotfiles repo changes
if [ -d .git ]; then
    echo "Updating dotfiles repo..."
    git pull
fi

# macOS-specific setup
if [ "$OS" = "Darwin" ]; then
    # Check/install Xcode Command Line Tools
    if ! xcode-select -p &> /dev/null; then
        echo "Installing Xcode Command Line Tools..."
        xcode-select --install
        echo "Please rerun this script after Xcode Command Line Tools installation completes."
        exit 1
    fi

    # Check/install Homebrew
    if ! command -v brew &> /dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    # Update and upgrade Homebrew
    brew update
    brew upgrade

    # Install CLI tools
    for pkg in nvim wezterm fzf ripgrep bat zoxide tmux htop git; do
        if ! command -v $pkg &> /dev/null; then
            brew install $pkg || brew install --cask $pkg
        fi
    done

    # Install starship
    if ! command -v starship &> /dev/null; then
        curl -sS https://starship.rs/install.sh | sh
    fi

    # Install pyenv
    if ! command -v pyenv &> /dev/null; then
        brew install pyenv
    fi

    # Install nvm
    if [ ! -d "$HOME/.nvm" ]; then
        brew install nvm
        mkdir -p ~/.nvm
        export NVM_DIR="$HOME/.nvm"
        source "$(brew --prefix nvm)/nvm.sh"
    fi

    # Install JetBrains Mono Nerd Font
    if ! fc-list | grep -qi "JetBrainsMono Nerd Font"; then
        brew tap homebrew/cask-fonts
        brew install --cask font-jetbrains-mono-nerd-font
    fi

    # Set macOS defaults (show hidden files in Finder)
    defaults write com.apple.finder AppleShowAllFiles -bool true
    killall Finder || true

else # Linux/WSL
    # Install CLI tools (assumes apt-get, adjust for your distro)
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y neovim wezterm fzf ripgrep bat zoxide tmux htop git curl
    fi

    # Install starship
    if ! command -v starship &> /dev/null; then
        curl -sS https://starship.rs/install.sh | sh
    fi

    # Install pyenv
    if ! command -v pyenv &> /dev/null; then
        curl https://pyenv.run | bash
    fi

    # Install nvm
    if [ ! -d "$HOME/.nvm" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    fi

    # Install JetBrains Mono Nerd Font (Linux)
    if ! fc-list | grep -qi "JetBrainsMono Nerd Font"; then
        mkdir -p ~/.local/share/fonts
        wget -O ~/.local/share/fonts/JetBrainsMonoNerdFont.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
        unzip -o ~/.local/share/fonts/JetBrainsMonoNerdFont.zip -d ~/.local/share/fonts/JetBrainsMono/
        fc-cache -fv
    fi
fi

# Install zinit if not present
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    echo "Installing zinit..."
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# link dotfiles folders and files 

# Symlink nvim config
echo "Linking nvim config..."
mkdir -p "$HOME/.config"
link_with_backup "$(pwd)/nvim" "$HOME/.config/nvim"

echo "Linking starship config..."
link_with_backup "$(pwd)/starship/starship.toml" "$HOME/.config/starship.toml"

echo "Linking wezterm config..."
link_with_backup "$(pwd)/wezterm" "$HOME/.config/wezterm"

echo "Linking .zshrc..."
link_with_backup "$(pwd)/zshrc/.zshrc" "$HOME/.zshrc"

# Set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
fi

echo "Setup complete!"
echo "\nManual steps you may need to do:"
echo "- Set your terminal font to 'JetBrains Mono Nerd Font' for best experience."
echo "- Restart your terminal or source your .zshrc to apply changes."
echo "- For nvm/pyenv, you may need to add their init lines to your .zshrc if not already present."
echo "- For Linux, log out and back in if fonts or shells do not update immediately."

