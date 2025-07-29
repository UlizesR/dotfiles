# Zinit setup and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"

export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Set BREW_PREFIX if Homebrew is installed
if command -v brew >/dev/null 2>&1; then
  export BREW_PREFIX=$(brew --prefix)
else
  export BREW_PREFIX=""
fi

# Compilation flags (only if BREW_PREFIX is set)
if [[ -n "$BREW_PREFIX" ]]; then
  export CFLAGS="-I$BREW_PREFIX/include -I/usr/local/include -I/$BREW_PREFIX/opt/llvm/include"
  export LDFLAGS="-L$BREW_PREFIX/lib -L/usr/local/lib -L/$BREW_PREFIX/opt/llvm/lib"
  export CPPFLAGS="-I$BREW_PREFIX/include -I/usr/local/include -I/$BREW_PREFIX/opt/llvm/include"
  export PKG_CONFIG_PATH="$BREW_PREFIX/opt/llvm/lib/pkgconfig"
fi

# Python virtualenv setup
export WORKON_HOME=$HOME/.virtualenvs

# Add Python to PATH (macOS vs Linux)
if [[ "$OSTYPE" == "darwin"* ]]; then
  export PATH="/Library/Frameworks/Python.framework/Versions/3.12/bin:$PATH"
elif command -v python3 >/dev/null 2>&1; then
  export PATH="$(dirname $(command -v python3)):$PATH"
fi

# Aliases
alias zshconfig="nvim ~/.zshrc"
alias zshsource="source ~/.zshrc"
alias ls='ls --color'
alias vim='nvim'
alias c='clear'

# Plugins via zinit
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
# zsh-syntax-highlighting should be last
zinit light zsh-users/zsh-syntax-highlighting

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

autoload -Uz compinit && compinit

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd cd zsh)"
fi

zinit cdreplay -q

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
eval "$(fzf --zsh)"
eval "$(starship init zsh)"
export PATH="$HOME/CodeProjects/libgen/tools:$PATH"
