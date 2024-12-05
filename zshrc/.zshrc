# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='nvim'
fi

export BREW_PREFIX=$(brew --prefix)

# Compilation flags
# export ARCHFLAGS="-arch x86_64"
export INCFLAGS="-I/$BREW_PREFIX/include -I/usr/local/include"
export CFLAGS="-std=c17 $INCFLAGS"
export CPPFLAGS="-std=c++17 $INCFLAGS"
export LDFLAGS="-L/$BREW_PREFIX/lib -L/usr/local/lib"
export PATH="/$BREW_PREFIX/opt/llvm/bin:$PATH"
export LDFLAGS="-L/$BREW_PREFIX/opt/llvm/lib"
export CPPFLAGS="-I/$BREW_PREFIX/opt/llvm/include"

# set up virtual environment for python
export WORKON_HOME=$HOME/.virtualenvs

# Example aliases
alias zshconfig="nvim ~/.zshrc"
alias zshsource="source ~/.zshrc"

source $BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# disable underline
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[default]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none

# activate auto-suggestions
source $BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh


# ~/.zshrc

eval "$(starship init zsh)"

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

path=('/Users/uliraudales/.juliaup/bin' $path)
export PATH

# <<< juliaup initialize <<<

