# ── Zinit bootstrap ───────────────────────────────────────────────────────────
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"

# ── OS / distro detection ─────────────────────────────────────────────────────
export OS_TYPE="$(uname -s)"   # Darwin | Linux
DISTRO_ID="unknown"
if [[ "$OS_TYPE" == "Linux" ]]; then
  if [[ -f /etc/os-release ]]; then
    DISTRO_ID="$(. /etc/os-release && echo "${ID}")"
  elif [[ -f /etc/arch-release ]]; then
    DISTRO_ID="arch"
  fi
fi

# ── Homebrew ──────────────────────────────────────────────────────────────────
_init_brew() {
  local p
  for p in /opt/homebrew/bin/brew /usr/local/bin/brew \
            /home/linuxbrew/.linuxbrew/bin/brew "${HOME}/.linuxbrew/bin/brew"; do
    if [[ -x "$p" ]]; then
      eval "$("$p" shellenv)"
      return 0
    fi
  done
}
# Only init Homebrew on macOS, Ubuntu, or Debian (skip Arch – native pacman)
if [[ "$OS_TYPE" == "Darwin" ]] || \
   [[ "$DISTRO_ID" == "ubuntu" || "$DISTRO_ID" == "debian" ]]; then
  _init_brew
fi
unset -f _init_brew

# Cache BREW_PREFIX once (brew --prefix spawns a process; do it once)
if command -v brew &>/dev/null; then
  export BREW_PREFIX="$(brew --prefix)"
else
  export BREW_PREFIX=""
fi

# ── Locale / editor ───────────────────────────────────────────────────────────
export LANG=en_US.UTF-8
export EDITOR="${SSH_CONNECTION:+vim}${SSH_CONNECTION:-nvim}"

# ── C / C++ toolchain ─────────────────────────────────────────────────────────
# Sets up Homebrew LLVM when present, while keeping Apple's clang first on PATH
# so that Objective-C / Apple-framework code still works out of the box.
if [[ -n "$BREW_PREFIX" && -d "${BREW_PREFIX}/opt/llvm" ]]; then
  _LLVM="${BREW_PREFIX}/opt/llvm"

  # Headers
  export CFLAGS="-I${_LLVM}/include"
  export CXXFLAGS="-I${_LLVM}/include -I${_LLVM}/include/c++/v1"
  export CPPFLAGS="-I${_LLVM}/include"

  # Libraries – link against Homebrew's libc++ and add an rpath so the binary
  # finds it at runtime without LD_LIBRARY_PATH tricks.
  export LDFLAGS="-L${_LLVM}/lib -L${_LLVM}/lib/c++ -Wl,-rpath,${_LLVM}/lib/c++"

  export PKG_CONFIG_PATH="${_LLVM}/lib/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}}"

  # Homebrew LLVM binaries (clang-XX, lld, etc.) are available via PATH;
  # /usr/bin comes first so `clang` still resolves to Apple Clang on macOS.
  if [[ "$OS_TYPE" == "Darwin" ]]; then
    export SDKROOT="$(xcrun --sdk macosx --show-sdk-path 2>/dev/null)"
    export PATH="/usr/bin:${_LLVM}/bin:${PATH}"
  else
    export PATH="${_LLVM}/bin:${PATH}"
  fi

  unset _LLVM
elif [[ "$OS_TYPE" == "Linux" ]] && command -v clang &>/dev/null; then
  # System LLVM on Linux – at least expose standard include/lib paths
  _SYS_INC="/usr/include"
  _SYS_LIB="/usr/lib"
  export CFLAGS="-I${_SYS_INC}"
  export CXXFLAGS="-I${_SYS_INC}"
  export CPPFLAGS="-I${_SYS_INC}"
  export LDFLAGS="-L${_SYS_LIB}"
  unset _SYS_INC _SYS_LIB
fi

# ── Python ────────────────────────────────────────────────────────────────────
# Prefer the newest Homebrew python@X.Y, otherwise fall back to system python3.
# This also ensures `python` and `pip` resolve correctly without hard-coding a version.
if [[ -n "$BREW_PREFIX" ]]; then
  # Pick the highest-versioned python@X.Y installed by brew
  _brew_py="$(ls -d "${BREW_PREFIX}/opt/python@"*/bin 2>/dev/null | sort -V | tail -1)"
  if [[ -n "$_brew_py" && -d "$_brew_py" ]]; then
    export PATH="${_brew_py}:${PATH}"
  fi
  unset _brew_py
fi

# Ensure `python` and `pip` always resolve even when only python3/pip3 exist
if ! command -v python &>/dev/null && command -v python3 &>/dev/null; then
  alias python=python3
fi
if ! command -v pip &>/dev/null && command -v pip3 &>/dev/null; then
  alias pip=pip3
fi

export WORKON_HOME="${HOME}/.virtualenvs"

# ── pyenv ─────────────────────────────────────────────────────────────────────
if [[ -d "${HOME}/.pyenv" ]]; then
  export PYENV_ROOT="${HOME}/.pyenv"
  export PATH="${PYENV_ROOT}/bin:${PATH}"
  eval "$(pyenv init -)"
fi

# ── nvm ───────────────────────────────────────────────────────────────────────
export NVM_DIR="${HOME}/.nvm"
if [[ -n "$BREW_PREFIX" && -s "${BREW_PREFIX}/opt/nvm/nvm.sh" ]]; then
  source "${BREW_PREFIX}/opt/nvm/nvm.sh"
elif [[ -s "${NVM_DIR}/nvm.sh" ]]; then
  source "${NVM_DIR}/nvm.sh"
fi

# ── bun ───────────────────────────────────────────────────────────────────────
export BUN_INSTALL="${HOME}/.bun"
if [[ -d "${BUN_INSTALL}/bin" ]]; then
  export PATH="${BUN_INSTALL}/bin:${PATH}"
  [[ -s "${BUN_INSTALL}/_bun" ]] && source "${BUN_INSTALL}/_bun"
fi

# ── User-local binaries ───────────────────────────────────────────────────────
[[ -d "${HOME}/.local/bin" ]] && export PATH="${HOME}/.local/bin:${PATH}"

# ── Aliases ───────────────────────────────────────────────────────────────────
alias zshconfig="${EDITOR} ~/.zshrc"
alias zshsource="source ~/.zshrc"
alias ls='ls --color=auto'
alias ll='ls -lh'
alias lla='ls -lah'
alias vim='nvim'

# ── WezTerm keybindings viewer ────────────────────────────────────────────────
# Usage: wezkeys [path/to/wezterm.lua]
# Parses the wezterm config and prints a formatted keybinding table.
wezkeys() {
  local config="${1:-${HOME}/.config/wezterm/wezterm.lua}"
  if [[ ! -f "$config" ]]; then
    echo "❌  WezTerm config not found: $config"
    return 1
  fi

  python3 - "$config" <<'PYEOF'
import re, sys

text = open(sys.argv[1]).read()

C_RESET  = "\033[0m"
C_BOLD   = "\033[1m"
C_CYAN   = "\033[36m"
C_YELLOW = "\033[33m"
C_DIM    = "\033[2m"

COL = (32, 42)  # (mods width, key width)
SEP = "  "
DIVIDER = "  " + (SEP.join("─" * w for w in (*COL, 20)))

print(f"\n  {C_BOLD}{C_CYAN}WezTerm Keybindings{C_RESET}\n{DIVIDER}")
print(f"  {C_BOLD}{'MODS':<{COL[0]}}{SEP}{'KEY':<{COL[1]}}{SEP}ACTION{C_RESET}")
print(DIVIDER)

# Match each { key = ... } block (may span multiple lines)
for blk in re.findall(r'\{[^{}]*key\s*=[^{}]*\}', text, re.DOTALL):
    key_m  = re.search(r'\bkey\s*=\s*"([^"]+)"',   blk)
    mods_m = re.search(r'\bmods\s*=\s*"([^"]+)"',  blk)
    act_m  = re.search(r'\baction\s*=\s*act\.(\w+(?:\s*\{[^}]*\})?)', blk, re.DOTALL)

    if not key_m:
        continue

    key  = key_m.group(1)
    mods = mods_m.group(1) if mods_m else "NONE"
    # Shorten multi-word actions to just the function name
    action = re.sub(r'\s*\{.*', '', act_m.group(1)).strip() if act_m else "—"

    mods_col = f"{C_YELLOW}{mods:<{COL[0]}}{C_RESET}"
    key_col  = f"{key:<{COL[1]}}"
    print(f"  {mods_col}{SEP}{key_col}{SEP}{action}")

print(DIVIDER + "\n")
PYEOF
}

# ── Zinit plugins ─────────────────────────────────────────────────────────────
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-syntax-highlighting   # must be last

# ── OMZ snippets ──────────────────────────────────────────────────────────────
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

autoload -Uz compinit && compinit
zinit cdreplay -q

# ── Key bindings ──────────────────────────────────────────────────────────────
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# ── History ───────────────────────────────────────────────────────────────────
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory sharehistory
setopt hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_find_no_dups

# ── Completion ────────────────────────────────────────────────────────────────
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*'          fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*'  fzf-preview 'ls --color $realpath'

# ── Tool integrations ─────────────────────────────────────────────────────────
command -v fzf     &>/dev/null && eval "$(fzf --zsh)"
command -v starship &>/dev/null && eval "$(starship init zsh)"
command -v zoxide  &>/dev/null && eval "$(zoxide init --cmd cd zsh)"

