#!/bin/bash

# Terminal Config Installation Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing terminal configs..."

link_config() {
    local source="$1"
    local target="$2"
    local name="$3"

    read -p "Overwrite $target? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$target"
        ln -s "$source" "$target"
        echo "  $name -> $target"
    else
        echo "  Skipped $name"
    fi
}

link_config "$SCRIPT_DIR/nvim" "$HOME/.config/nvim" "nvim"
link_config "$SCRIPT_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf" "tmux"
link_config "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc" "zsh"

# Check for Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    read -p "Oh My Zsh not found. Install it? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        echo "  Oh My Zsh installed!"
    fi
fi

# Check for Tmux Plugin Manager
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    read -p "Tmux Plugin Manager (tpm) not found. Install it? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
        echo "  tpm installed! Press prefix + I in tmux to install plugins."
    fi
fi

echo "Done! Restart your terminal or run: source ~/.zshrc"
