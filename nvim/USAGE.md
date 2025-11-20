# Neovim Configuration Usage Guide

## 🚀 Initial Setup

### First Time Setup
1. **Install plugins:**
   ```vim
   :Lazy sync
   ```

2. **Install LSP servers** (via Mason):
   ```vim
   :Mason
   ```
   Then install: `clangd` (C/C++), `lua_ls` (Lua), `pyright` (Python)

3. **Authenticate Copilot** (optional):
   ```vim
   :Copilot auth
   ```

4. **Update Treesitter parsers:**
   ```vim
   :TSUpdate
   ```

---

## ⌨️ Leader Key

Your leader key is **`<Space>`** (spacebar). All custom keymaps start with `<leader>`.

**Tip:** Press `<leader>?` to see all available keymaps in the current buffer!

---

## 📁 File Navigation

### File Explorer (Oil)
- **`-`** - Open file explorer (parent directory)
- Navigate with `j/k` (up/down)
- Press `Enter` to open files
- Press `-` again to go up a directory

**File Operations:**
- **`a`** - Create new file or directory (type name, end with `/` for directory)
- **`d`** - Delete file/directory
- **`r`** - Rename file/directory
- **`y`** - Copy file/directory
- **`x`** - Cut file/directory
- **`p`** - Paste file/directory

### Telescope (Fuzzy Finder)
- **`<leader>ff`** - Find files in current directory
- **`<leader>fg`** - Live grep (search text in files)
- **`<leader>fb`** - Find/open buffers
- **`<leader>fh`** - Help tags (Neovim documentation)
- **`<leader>en`** - Navigate to Neovim config directory

**Telescope Tips:**
- Type to filter results
- `<C-n>/<C-p>` - Navigate results
- `<Enter>` - Open selected
- `<Esc>` - Close Telescope

---

## ✏️ Code Editing

### Basic Navigation
- **`<C-h/j/k/l>`** - Move between windows (left/down/up/right)
- **`<Esc>`** - Clear search highlighting

### Line Manipulation
- **`<Alt-j>`** - Move line down
- **`<Alt-k>`** - Move line up
- Works in Normal, Insert, and Visual modes

### Indentation
- **`<`** (Visual mode) - Indent left and reselect
- **`>`** (Visual mode) - Indent right and reselect

### Comments
- **`gcc`** - Toggle comment on current line
- **`gc`** (Visual mode) - Toggle comment on selection

### Auto-pairs
- Automatically closes brackets, quotes, etc.
- Press closing character to skip over it

---

## 🔍 LSP (Language Server Protocol)

### Navigation
- **`gd`** - Go to definition
- **`gD`** - Go to declaration
- **`gi`** - Go to implementation
- **`gr`** - Find references
- **`K`** - Hover documentation
- **`<C-k>`** - Signature help (function parameters)
- **`<leader>D`** - Type definition

### Code Actions
- **`<leader>rn`** - Rename symbol
- **`<leader>ca`** - Code actions (fixes, refactors)
- **`<leader>f`** - Format file

### Diagnostics (Errors/Warnings)
- **`[d`** - Previous diagnostic
- **`]d`** - Next diagnostic
- **`<leader>e`** - Show diagnostic in floating window
- **`<leader>q`** - Add diagnostics to location list

### Workspace
- **`<leader>wa`** - Add workspace folder
- **`<leader>wr`** - Remove workspace folder
- **`<leader>wl`** - List workspace folders

### Format on Save
- Automatically formats files when you save (if LSP supports it)

---

## 🐛 Debugging (DAP)

### Setup
1. Install debug adapters via Mason: `cppdbg`, `python`
2. For C++: When starting debug, enter path to executable

### Keymaps
- **`<leader>dt`** - Toggle breakpoint
- **`<leader>dc`** - Continue/Start debugging
- **`<leader>dk`** - Terminate debugging
- **`<leader>dso`** - Step over
- **`<leader>dsi`** - Step into
- **`<leader>dsu`** - Step out
- **`<leader>dr`** - Open debug REPL
- **`<leader>du`** - Toggle DAP UI

**Note:** DAP UI opens automatically when debugging starts.

---

## 📊 Diagnostics & Symbols (Trouble)

- **`<leader>xx`** - Toggle diagnostics window
- **`<leader>xX`** - Toggle buffer diagnostics only
- **`<leader>cs`** - Toggle document symbols
- **`<leader>xL`** - Toggle location list
- **`<leader>xQ`** - Toggle quickfix list

**Tip:** Use Trouble to see all errors/warnings in a nice list view!

---

## 🪟 Window Management

### Splits
- **`<leader>sv`** - Split vertically
- **`<leader>sh`** - Split horizontally
- **`<leader>se`** - Make splits equal size
- **`<leader>sx`** - Close current split

### Navigation
- **`<C-h/j/k/l>`** - Move between windows

---

## 📑 Tab Management

- **`<leader>to`** - Open new tab
- **`<leader>tx`** - Close current tab
- **`<leader>tn`** - Next tab
- **`<leader>tp`** - Previous tab

---

## 🤖 AI Completions (Copilot)

Copilot suggestions appear automatically in your completion menu (highest priority).

**To use:**
1. Start typing code
2. Copilot suggestions appear with `[Copilot]` label
3. Use `<Tab>` to accept, or continue typing

**Commands:**
- **`:Copilot auth`** - Authenticate with GitHub
- **`:Copilot status`** - Check authentication status

---

## 🎨 Completion Menu (nvim-cmp)

### Navigation
- **`<Tab>`** - Next item (or expand snippet)
- **`<S-Tab>`** - Previous item (or jump back in snippet)
- **`<C-Space>`** - Trigger completion
- **`<C-e>`** - Close completion menu
- **`<Enter>`** - Confirm selection

### Documentation
- **`<C-d>`** - Scroll docs up
- **`<C-f>`** - Scroll docs down

**Completion Sources (priority order):**
1. Copilot (AI)
2. LSP (language server)
3. Snippets
4. File paths
5. Buffer text

---

## 🎨 Appearance

### Colorscheme
- **Catppuccin Macchiato** (dark theme)
- Transparent background enabled

### Status Line
- Shows: mode, file path, git status, LSP status, cursor position

---

## 📝 Code Formatting

### Automatic
- Files format automatically on save (via LSP or conform.nvim)

### Manual
- **`<leader>f`** - Format current file

### Supported Languages
- **Lua** - stylua
- **Python** - black, isort
- **C/C++** - clang-format
- **Others** - Via LSP

---

## 🔧 Useful Commands

### Plugin Management
- **`:Lazy`** - Open Lazy plugin manager
- **`:Lazy sync`** - Install/update plugins
- **`:Lazy clean`** - Remove unused plugins

### LSP
- **`:Mason`** - Open Mason (LSP installer)
- **`:LspInfo`** - Show LSP server info
- **`:LspRestart`** - Restart LSP server

### Treesitter
- **`:TSUpdate`** - Update all parsers
- **`:TSInstall <language>`** - Install specific parser
- **`:TSBufToggle highlight`** - Toggle syntax highlighting

### Other
- **`:Trouble`** - Open Trouble diagnostics
- **`:Oil`** - Open file explorer
- **`:Telescope`** - Open Telescope picker

---

## 🎯 Common Workflows

### Starting a New Project
1. Open directory: `nvim .`
2. Install LSP servers: `:Mason`
3. Start coding!

### Finding Code
1. **`<leader>fg`** - Search for text across files
2. **`<leader>ff`** - Find specific file
3. **`gr`** - Find all references to symbol

### Debugging C++
1. Compile your code
2. **`<leader>dt`** - Set breakpoints
3. **`<leader>dc`** - Start debugging (enter executable path)
4. Use step commands to navigate

### Fixing Errors
1. **`]d`** - Jump to next error
2. **`<leader>ca`** - See code actions (auto-fixes)
3. **`<leader>xx`** - View all diagnostics in Trouble

### Git Workflow
- Git indicators show in gutter (gitsigns)
- **`+`** - Added line
- **`~`** - Modified line
- **`_`** - Deleted line

---

## 💡 Pro Tips

1. **Use Which-Key:** Press `<leader>` and wait - see all available commands!
2. **Quick Config Edit:** `<leader>en` opens your Neovim config
3. **Multiple Files:** Use splits (`<leader>sv`/`<leader>sh`) for side-by-side editing
4. **Search Everywhere:** `<leader>fg` searches across all files instantly
5. **Format on Save:** Just save, formatting happens automatically!

---

## 🆘 Troubleshooting

### LSP not working?
- Check: `:LspInfo`
- Restart: `:LspRestart`
- Install server: `:Mason`

### No syntax highlighting?
- Update parsers: `:TSUpdate`
- Check filetype: `:set filetype?`

### Copilot not working?
- Authenticate: `:Copilot auth`
- Check Node.js: `:!node --version`

### Plugins not loading?
- Sync: `:Lazy sync`
- Check errors: `:Lazy`

---

## 📚 Language Support

### Fully Supported (LSP + Treesitter)
- **C/C++** - clangd
- **Lua** - lua_ls
- **Python** - pyright

### Syntax Highlighting Only
- **Objective-C** (`.m`, `.h`)
- **Objective-C++** (`.mm`)
- **OpenCL** (`.cl`)
- **Metal** (`.metal`)
- **GLSL** (`.glsl`, `.vert`, `.frag`)
- **HLSL** (`.hlsl`)
- **Bash**, **JSON**, **Markdown**, **Vim**

---

Enjoy your powerful Neovim setup! 🚀

