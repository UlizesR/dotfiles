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

echo "🚀 Starting development environment setup..."

# Detect OS
OS=$(uname -s)
echo "📋 Detected OS: $OS"

# Pull latest dotfiles repo changes
if [ -d .git ]; then
    echo "📥 Updating dotfiles repo..."
    git pull
    echo "✅ Dotfiles repo updated"
else
    echo "⚠️  Not in a git repository, skipping repo update"
fi

# Ensure zsh is installed
echo "🐚 Checking zsh installation..."
if ! command -v zsh &> /dev/null; then
    echo "📦 Installing zsh..."
    if [ "$OS" = "Darwin" ]; then
        brew install zsh
    else
        sudo apt-get install -y zsh
    fi
    echo "✅ zsh installed successfully"
else
    echo "✅ zsh is already installed"
fi

# macOS-specific setup
if [ "$OS" = "Darwin" ]; then
    echo "🍎 Setting up macOS environment..."
    
    # Check/install Xcode Command Line Tools
    if ! xcode-select -p &> /dev/null; then
        echo "🔧 Installing Xcode Command Line Tools..."
        xcode-select --install
        echo "⚠️  Please rerun this script after Xcode Command Line Tools installation completes."
        exit 1
    else
        echo "✅ Xcode Command Line Tools already installed"
    fi

    # Check/install Homebrew
    if ! command -v brew &> /dev/null; then
        echo "🍺 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo "✅ Homebrew installed successfully"
    else
        echo "✅ Homebrew already installed"
    fi

    # Update and upgrade Homebrew
    echo "🔄 Updating Homebrew packages..."
    brew update
    brew upgrade
    echo "✅ Homebrew packages updated"

    # Install CLI tools
    echo "📦 Installing CLI tools..."
    for pkg in nvim fzf ripgrep bat zoxide tmux htop git; do
        if ! command -v $pkg &> /dev/null; then
            echo "  Installing $pkg..."
            brew install $pkg || brew install --cask $pkg
            echo "  ✅ $pkg installed"
        else
            echo "  ✅ $pkg already installed"
        fi
    done

    # Install starship
    if ! command -v starship &> /dev/null; then
        echo "⭐ Installing starship..."
        curl -sS https://starship.rs/install.sh | sh
        echo "✅ starship installed"
    else
        echo "✅ starship already installed"
    fi

    # Install pyenv (only if not already installed)
    if ! command -v pyenv &> /dev/null; then
        echo "🐍 Installing pyenv..."
        brew install pyenv
        echo "✅ pyenv installed"
    else
        echo "✅ pyenv already installed"
    fi

    # Install nvm (only if not already installed)
    if [ ! -d "$HOME/.nvm" ]; then
        echo "📦 Installing nvm..."
        brew install nvm
        mkdir -p ~/.nvm
        export NVM_DIR="$HOME/.nvm"
        source "$(brew --prefix nvm)/nvm.sh"
        echo "✅ nvm installed"
    else
        echo "✅ nvm already installed"
    fi

    # Install JetBrains Mono Nerd Font
    if ! fc-list | grep -qi "JetBrainsMono Nerd Font"; then
        echo "🔤 Installing JetBrains Mono Nerd Font..."
        brew tap homebrew/cask-fonts
        brew install --cask font-jetbrains-mono-nerd-font
        echo "✅ JetBrains Mono Nerd Font installed"
    else
        echo "✅ JetBrains Mono Nerd Font already installed"
    fi

    # Set macOS defaults (show hidden files in Finder)
    echo "⚙️  Setting macOS defaults..."
    defaults write com.apple.finder AppleShowAllFiles -bool true
    killall Finder || true
    echo "✅ macOS defaults configured"

else # Linux/WSL
    echo "🐧 Setting up Linux environment..."
    
    # Install CLI tools (assumes apt-get, adjust for your distro)
    if command -v apt-get &> /dev/null; then
        echo "📦 Installing CLI tools..."
        sudo apt-get update
        sudo apt-get install -y neovim fzf ripgrep bat zoxide tmux htop git curl
        echo "✅ CLI tools installed"
    else
        echo "⚠️  apt-get not found, please install CLI tools manually"
    fi

    # Install starship
    if ! command -v starship &> /dev/null; then
        echo "⭐ Installing starship..."
        curl -sS https://starship.rs/install.sh | sh
        echo "✅ starship installed"
    else
        echo "✅ starship already installed"
    fi

    # Install pyenv (only if not already installed)
    if ! command -v pyenv &> /dev/null; then
        echo "🐍 Installing pyenv..."
        curl https://pyenv.run | bash
        echo "✅ pyenv installed"
    else
        echo "✅ pyenv already installed"
    fi

    # Install nvm (only if not already installed)
    if [ ! -d "$HOME/.nvm" ]; then
        echo "📦 Installing nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        echo "✅ nvm installed"
    else
        echo "✅ nvm already installed"
    fi

    # Install JetBrains Mono Nerd Font (Linux)
    if ! fc-list | grep -qi "JetBrainsMono Nerd Font"; then
        echo "🔤 Installing JetBrains Mono Nerd Font..."
        mkdir -p ~/.local/share/fonts
        wget -O ~/.local/share/fonts/JetBrainsMonoNerdFont.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
        unzip -o ~/.local/share/fonts/JetBrainsMonoNerdFont.zip -d ~/.local/share/fonts/JetBrainsMono/
        fc-cache -fv
        echo "✅ JetBrains Mono Nerd Font installed"
    else
        echo "✅ JetBrains Mono Nerd Font already installed"
    fi
fi

# Install zinit if not present
echo "🔌 Installing zinit..."
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
    echo "✅ zinit installed"
else
    echo "✅ zinit already installed"
fi

# Link dotfiles folders and files
echo "🔗 Linking dotfiles..."

# Symlink nvim config
echo "  Linking nvim config..."
mkdir -p "$HOME/.config"
link_with_backup "$(pwd)/nvim" "$HOME/.config/nvim"

echo "  Linking starship config..."
link_with_backup "$(pwd)/starship/starship.toml" "$HOME/.config/starship.toml"

echo "  Linking wezterm config..."
link_with_backup "$(pwd)/wezterm" "$HOME/.config/wezterm"

echo "  Linking .zshrc..."
link_with_backup "$(pwd)/zshrc/.zshrc" "$HOME/.zshrc"

# Install and set zsh as default shell
echo "🐚 Setting zsh as default shell..."
if command -v zsh &> /dev/null; then
    ZSH_PATH=$(which zsh)
    if grep -q "$ZSH_PATH" /etc/shells; then
        if [ "$SHELL" != "$ZSH_PATH" ]; then
            chsh -s "$ZSH_PATH"
            echo "✅ Default shell changed to zsh. Please log out and back in for changes to take effect."
        else
            echo "✅ zsh is already the default shell"
        fi
    else
        echo "⚠️  zsh is not in /etc/shells. Please add it manually or run: sudo echo '$ZSH_PATH' >> /etc/shells"
    fi
else
    echo "❌ zsh installation failed. Please install it manually."
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📋 Manual steps you may need to do:"
echo "  - Set your terminal font to 'JetBrains Mono Nerd Font' for best experience."
echo "  - Restart your terminal or source your .zshrc to apply changes."
echo "  - For nvm/pyenv, you may need to add their init lines to your .zshrc if not already present."
echo "  - For Linux, log out and back in if fonts or shells do not update immediately."
echo ""
echo "🔧 To apply changes immediately, run: source ~/.zshrc"

