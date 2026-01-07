# term-config

My terminal configuration for nvim, tmux, zsh, and wezterm. In case anybody is interested.

## Installation

```bash
git clone https://github.com/minhnhut/term-config.git
cd term-config
./install.sh
```

This creates symlinks:
- `nvim/` -> `~/.config/nvim`
- `tmux/.tmux.conf` -> `~/.tmux.conf`
- `zsh/.zshrc` -> `~/.zshrc`
- `wezterm/.wezterm.lua` -> `~/.wezterm.lua`

## What's Inside

### WezTerm
- **Font**: BlexMono Nerd Font Mono (size 15)
- **Color scheme**: Dracula
- **Window**: 120x28 initial size, hides tab bar when only one tab

### Neovim (based on Kickstart.nvim)
- **Color scheme**: Dracula
- **File explorer**: nvim-tree (toggle with `<Space>e`)
- **Fuzzy finder**: Telescope
  - `<Space>sf` - Search files
  - `<Space>sg` - Live grep
  - `<Space>sb` - Search buffers
  - `<Space>/` - Fuzzy search in current buffer
- **Buffer management**: bufferline
  - `<Tab>` / `<S-Tab>` - Next/previous buffer
  - `<Space>bb` - Search buffers
  - `<Space>bp` - Pick buffer
  - `<Space>bx` - Close current buffer
  - `<Space>bc` - Pick buffer to close
  - `<Space>bo` - Close other buffers
  - `<Space>bl` / `<Space>br` - Close buffers to left/right
- **Window management**:
  - `<Space>wh/j/k/l` - Navigate windows
  - `<Space>ws` / `<Space>wv` - Split horizontal/vertical
  - `<Space>wc` - Close window
  - `<Space>wo` - Close other windows
  - `<Space>w=` - Equalize window sizes
- **LSP**: mason + lspconfig with auto-install
- **Completion**: blink.cmp with LuaSnip
- **Laravel development**: laravel.nvim
  - `<Space>la` - Artisan picker
  - `<Space>lr` - Routes picker
  - `<Space>lm` - Make picker
- **Other**: gitsigns, which-key, treesitter, conform (formatting)

### Tmux
- **Prefix**: `Ctrl+a` (instead of default `Ctrl+b`)
- **Mouse**: Enabled
- **Status bar**: Top, Dracula-themed with CPU, memory, battery
- **Navigation**:
  - `Ctrl+h/j/k/l` - Switch panes (vim-style)
  - `Ctrl+q` / `Ctrl+e` - Previous/next window
- **Windows/Panes**:
  - `prefix + c` - New window
  - `prefix + "` - Split horizontal
  - `prefix + %` - Split vertical
- **Session**:
  - `prefix + Ctrl+s` - Save session (resurrect)
  - `prefix + Ctrl+r` - Restore session (resurrect)
  - `prefix + r` - Reload config
- **Copy mode**: vi keys, `[` to enter, `y` to copy
- **Plugins**: tpm, tmux-resurrect, tmux-battery, tmux-cpu-mem-monitor

### Zsh
- **Framework**: Oh My Zsh
- **Theme**: bira
- **Plugins**: git, zsh-autosuggestions, zsh-syntax-highlighting, fast-syntax-highlighting, rclone

## Terminal Secrets (Personal choice)

For private environment variables, I put them all in a folder `~/Terminal` on my machine, it is simply symlinked from my mounted OneDrive folder. It looks like this on my end:

```bash
ln -s "/path/to/OneDrive/Terminal" "$HOME/Terminal"
```

The `.zshrc` will automatically source it if it exists. You may don't need this.

## Requirements

- [WezTerm](https://wezfurlong.org/wezterm/)
- [Oh My Zsh](https://ohmyz.sh/)
- [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
- [Neovim](https://neovim.io/)
- [BlexMono Nerd Font](https://www.nerdfonts.com/)
