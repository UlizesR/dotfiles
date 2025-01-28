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
export CFLAGS="-I$BREW_PREFIX/include -I/usr/local/include -I/$BREW_PREFIX/opt/llvm/include"
export LDFLAGS="-L$BREW_PREFIX/lib -L/usr/local/lib -L/$BREW_PREFIX/opt/llvm/lib"
export CPPFLAGS="-I$BREW_PREFIX/include -I/usr/local/include -I/$BREW_PREFIX/opt/llvm/include"
export PKG_CONFIG_PATH="$BREW_PREFIX/opt/llvm/lib/pkgconfig"


# set up virtual environment for python
export WORKON_HOME=$HOME/.virtualenvs
export PATH="/Library/Frameworks/Python.framework/Versions/3.12/bin:$PATH"

# Example aliases
alias zshconfig="nvim ~/.zshrc"
alias zshsource="source ~/.zshrc"

# if macOS use BREW_PREFIX for the zsh-syntax-highlighting and zsh-autosuggestions plugins
# otherwise use usr/ prefix
if [[ "$OSTYPE" == "darwin"* ]]; then
    source $BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
else
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

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
