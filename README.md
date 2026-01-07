# term-config

My terminal configuration for nvim, tmux, and zsh.

## Installation

```bash
git clone https://github.com/nhuttran/term-config.git
cd term-config
./install.sh
```

This creates symlinks:
- `nvim/` -> `~/.config/nvim`
- `tmux/.tmux.conf` -> `~/.tmux.conf`
- `zsh/.zshrc` -> `~/.zshrc`

## Terminal Secrets (Optional)

For private environment variables, create a `~/Terminal/env` file (e.g., symlinked from OneDrive):

```bash
ln -s "/path/to/OneDrive/Terminal" "$HOME/Terminal"
```

The `.zshrc` will automatically source it if it exists.

## Requirements

- [Oh My Zsh](https://ohmyz.sh/)
- [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)
- Neovim
