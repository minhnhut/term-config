# term-config

My terminal configuration for nvim, tmux, zsh and kitty. In case anybody is interested.

## Installation

```bash
git clone https://github.com/minhnhut/term-config.git
cd term-config
./install.sh
```

The first run asks which configs to install and saves the answers to
`~/.config/term-config/choices`. Later runs apply the saved choices without
asking (handy after a `git pull`). To change your choices:

```bash
./install.sh --config
```

Works on macOS, Linux, [Omarchy](https://omarchy.org/) and Windows (Git Bash).
Only configs that make sense on the platform are offered, and existing configs
are backed up to `<path>.bak.<timestamp>`. Deselecting a config removes its
link and restores the latest backup.

| Config | Link |
|---|---|
| Neovim | `nvim/` -> `~/.config/nvim` (Windows: `%LOCALAPPDATA%\nvim`) |
| tmux | `tmux/.tmux.conf` -> `~/.config/tmux/tmux.conf` |
| zsh | `~/.zshrc` stays per machine and sources `zsh/extras.zsh` |
| Terminal | Asks which terminal you use: foot or kitty on Linux, kitty or none on macOS. Picking kitty links `kitty/` -> `~/.config/kitty`; foot keeps its own config. On Omarchy it also becomes the default terminal (installed first if needed). |

On Omarchy, everything follows the current Omarchy theme: Neovim (when it
starts) and kitty load its colours, and tmux backgrounds are transparent so the
terminal's theme shows through. Everywhere else they use Dracula.

On Windows, symlinks need Developer Mode enabled.

## What's Inside

### Kitty
- **Font**: FiraMono Nerd Font Mono (size 14)
- **Color scheme**: Dracula, or the current Omarchy theme on Omarchy
- **Keys**: `Shift+Enter` sends a distinct escape sequence (for TUI apps that use it)

### Neovim (based on Kickstart.nvim)
- **Color scheme**: follows the Omarchy theme on Omarchy, Dracula elsewhere
- **Statusline**: lualine.nvim with mode icons (, , , , , )
- **File explorer**: nvim-tree (toggle with `<Space>e`)
  - `c` - CD into selected folder
  - `-` - Go to parent directory
  - Parent folder shown as `󰁝 ..` instead of full path
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

- [kitty](https://sw.kovidgoyal.net/kitty/)
- [Oh My Zsh](https://ohmyz.sh/)
- [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
- [Neovim](https://neovim.io/)
- [FiraMono Nerd Font](https://www.nerdfonts.com/)
