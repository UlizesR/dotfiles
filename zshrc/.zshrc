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
# Only init Homebrew on macOS, Ubuntu, or Debian (skip Arch -- native pacman)
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
if [[ -n "$SSH_CONNECTION" ]]; then
  export EDITOR="vim"   # lighter weight over a remote session
else
  export EDITOR="nvim"
fi

# ── C / C++ toolchain ─────────────────────────────────────────────────────────
# Puts Homebrew LLVM on PATH when present, ahead of Apple's clang, while
# keeping /usr/bin first on macOS so Objective-C / Apple-framework code still
# builds against the system SDK by default.
#
# No CFLAGS/CXXFLAGS/LDFLAGS/PKG_CONFIG_PATH exported globally on purpose --
# those silently leak into every C/C++ build on the system, including
# unrelated projects with their own flags. Per-project build systems
# (cmake/meson/cargo) should be the ones passing include/lib paths.
if [[ -n "$BREW_PREFIX" && -d "${BREW_PREFIX}/opt/llvm" ]]; then
  _LLVM="${BREW_PREFIX}/opt/llvm"
  if [[ "$OS_TYPE" == "Darwin" ]]; then
    export SDKROOT="$(xcrun --sdk macosx --show-sdk-path 2>/dev/null)"
    export PATH="/usr/bin:${_LLVM}/bin:${PATH}"
  else
    export PATH="${_LLVM}/bin:${PATH}"
  fi
  unset _LLVM
fi

# ── Python ────────────────────────────────────────────────────────────────────
# Prefer the newest Homebrew python@X.Y, otherwise fall back to system python3.
if [[ -n "$BREW_PREFIX" ]]; then
  _brew_py="$(ls -d "${BREW_PREFIX}/opt/python@"*/bin 2>/dev/null | sort -V | tail -1)"
  if [[ -n "$_brew_py" && -d "$_brew_py" ]]; then
    export PATH="${_brew_py}:${PATH}"
  fi
  unset _brew_py
fi

if ! command -v python &>/dev/null && command -v python3 &>/dev/null; then
  alias python=python3
fi
if ! command -v pip &>/dev/null && command -v pip3 &>/dev/null; then
  alias pip=pip3
fi

# ── pyenv (lazy) ──────────────────────────────────────────────────────────────
# Shims go on PATH immediately -- that alone is enough for `python`/`pip` to
# pick the right version via .python-version files, since that's how pyenv
# shims work regardless of shell integration. The heavier `pyenv init -`
# (completions, the `cd` hook, `pyenv shell`/`pyenv local` mutating the
# current shell) is deferred until the `pyenv` command is actually run.
if [[ -d "${HOME}/.pyenv" ]]; then
  export PYENV_ROOT="${HOME}/.pyenv"
  export PATH="${PYENV_ROOT}/bin:${PYENV_ROOT}/shims:${PATH}"
  pyenv() {
    unset -f pyenv
    eval "$(command pyenv init -)"
    pyenv "$@"
  }
fi

# ── nvm (lazy) ────────────────────────────────────────────────────────────────
# nvm.sh is one of the most commonly cited slow-shell-startup culprits.
# Stub functions defer actually sourcing it until nvm/node/npm/npx is first
# invoked, then replace themselves with the real thing for the rest of the
# session.
export NVM_DIR="${HOME}/.nvm"
_nvm_lazy_load() {
  local nvm_sh
  if [[ -n "$BREW_PREFIX" && -s "${BREW_PREFIX}/opt/nvm/nvm.sh" ]]; then
    nvm_sh="${BREW_PREFIX}/opt/nvm/nvm.sh"
  elif [[ -s "${NVM_DIR}/nvm.sh" ]]; then
    nvm_sh="${NVM_DIR}/nvm.sh"
  else
    return 1
  fi
  unset -f nvm node npm npx _nvm_lazy_load
  source "$nvm_sh"
}
nvm()  { _nvm_lazy_load && nvm "$@"; }
node() { _nvm_lazy_load && node "$@"; }
npm()  { _nvm_lazy_load && npm "$@"; }
npx()  { _nvm_lazy_load && npx "$@"; }

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
# `wait lucid` defers each load to right after the first prompt draws instead
# of blocking shell startup on them -- this is the standard zinit "turbo mode"
# pattern and is the single biggest win here, since these four plugins were
# previously loaded synchronously every single shell start.
zinit ice wait lucid blockf   # blockf: let zsh-completions own its fpath entries cleanly
zinit light zsh-users/zsh-completions

zinit ice wait lucid
zinit light zsh-users/zsh-autosuggestions

zinit ice wait lucid
zinit light Aloxaf/fzf-tab

zinit ice wait lucid
zinit light zsh-users/zsh-syntax-highlighting   # must load last among these

# ── OMZ snippets ──────────────────────────────────────────────────────────────
# Same turbo treatment -- none of these need to be ready before the prompt
# actually appears. aws/kubectl/kubectx dropped entirely (unused).
zinit ice wait lucid
zinit snippet OMZL::git.zsh

zinit ice wait lucid
zinit snippet OMZP::git

zinit ice wait lucid
zinit snippet OMZP::sudo

if [[ "$DISTRO_ID" == "arch" ]]; then
  zinit ice wait lucid
  zinit snippet OMZP::archlinux
fi

zinit ice wait lucid
zinit snippet OMZP::command-not-found

# compinit: only do the full (slower) scan once a day; otherwise skip zsh's
# insecure-directory check with -C and just reuse yesterday's dump. This is
# the standard cached-compinit idiom, not a zinit-specific feature.
autoload -Uz compinit
if [[ -n "${ZDOTDIR:-$HOME}/.zcompdump"(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
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
setopt appendhistory sharehistory
setopt hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_find_no_dups

# ── Completion ────────────────────────────────────────────────────────────────
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*'          fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*'  fzf-preview 'ls --color $realpath'

# ── Tool integrations ─────────────────────────────────────────────────────────
command -v fzf      &>/dev/null && eval "$(fzf --zsh)"
command -v starship &>/dev/null && eval "$(starship init zsh)"
command -v zoxide   &>/dev/null && eval "$(zoxide init --cmd cd zsh)"
