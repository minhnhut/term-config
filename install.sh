#!/usr/bin/env bash

# Terminal Config Installation Script
#
# Usage:
#   ./install.sh            Apply saved choices (asks on the first run)
#   ./install.sh --config   Choose again which configs to install
#
# Works on macOS (bash 3.2), Linux, Omarchy and Windows (Git Bash).
# Existing configs are backed up to <path>.bak.<timestamp>, never deleted.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHOICES_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/term-config/choices"

usage() {
    sed -n '3,10p' "$0" | sed 's/^# \{0,1\}//'
}

RECONFIGURE=false
case "${1:-}" in
    "") ;;
    -c|--config) RECONFIGURE=true ;;
    -h|--help) usage; exit 0 ;;
    *) usage; exit 1 ;;
esac

# ----------------------------
# PLATFORM
# ----------------------------

case "$(uname -s)" in
    Darwin) PLATFORM=mac ;;
    MINGW*|MSYS*|CYGWIN*) PLATFORM=windows ;;
    *)
        if [ -n "$OMARCHY_PATH" ] || [ -d /usr/share/omarchy ]; then
            PLATFORM=omarchy
        else
            PLATFORM=linux
        fi
        ;;
esac

echo "Platform: $PLATFORM"

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
NVIM_TARGET="$CONFIG_HOME/nvim"

if [ "$PLATFORM" = windows ]; then
    # Make ln create real symlinks (needs Developer Mode) instead of silently copying
    export MSYS=winsymlinks:nativestrict
    NVIM_TARGET="$(cygpath -u "$LOCALAPPDATA")/nvim"
fi

# name|repo path|target|description
# zsh is special: ~/.zshrc stays per-machine and sources zsh/extras.zsh.
COMPONENTS="
nvim|nvim|$NVIM_TARGET|Neovim (Kickstart)
tmux|tmux/.tmux.conf|$CONFIG_HOME/tmux/tmux.conf|tmux
zsh|zsh/extras.zsh|$HOME/.zshrc|zsh + Oh My Zsh
"

# Components that make no sense on a platform are never offered
is_supported() {
    case "$PLATFORM:$1" in
        windows:tmux|windows:zsh) return 1 ;;
        *) return 0 ;;
    esac
}

is_installed() {
    command -v "$1" >/dev/null 2>&1 && return 0
    case "$PLATFORM:$1" in
        mac:kitty) [ -d /Applications/kitty.app ] ;;
        *) return 1 ;;
    esac
}

# Suggested answer when there is no saved choice yet
default_choice() {
    if is_installed "$1"; then echo y; else echo n; fi
}

saved_choice() {
    if [ -f "$CHOICES_FILE" ]; then
        sed -n "s/^$1=//p" "$CHOICES_FILE" | tail -1
    fi
}

ask() {
    local name="$1" description="$2" default="$3" hint="[y/N]"
    [ "$default" = y ] && hint="[Y/n]"
    # Prompts read from the terminal: stdin is the component list
    read -r -n 1 -p "Install $description config? $hint " REPLY < /dev/tty
    [ -n "$REPLY" ] && echo >&2
    case "$REPLY" in
        [Yy]) echo y ;;
        [Nn]) echo n ;;
        *) echo "$default" ;;
    esac
}

# ----------------------------
# TERMINAL
# ----------------------------

# Terminals offered per platform, first one is the fallback default.
# foot has no config here: it keeps its own (on Omarchy, the themed one).
terminal_options() {
    case "$PLATFORM" in
        omarchy|linux) echo "foot kitty" ;;
        mac) echo "kitty none" ;;
    esac
}

current_terminal() {
    if [ "$PLATFORM" = omarchy ]; then
        omarchy-default-terminal 2>/dev/null || true
    fi
}

default_terminal() {
    local options="$1" current
    current="$(current_terminal)"
    if [ -n "$current" ]; then
        case " $options " in *" $current "*) echo "$current"; return ;; esac
    fi
    # Older versions of this script saved kitty=y|n
    if [ "$(saved_choice kitty)" = y ]; then
        case " $options " in *" kitty "*) echo kitty; return ;; esac
    fi
    echo "${options%% *}"
}

ask_terminal() {
    local options="$1" default="$2" option
    read -r -p "Which terminal do you use? (${options// //}) [$default] " REPLY < /dev/tty
    if [ -n "$REPLY" ]; then
        for option in $options; do
            case "$option" in "$REPLY"*) echo "$option"; return ;; esac
        done
    fi
    echo "$default"
}

apply_terminal() {
    local terminal="$1" source="$SCRIPT_DIR/kitty" target="$CONFIG_HOME/kitty"

    if [ "$terminal" = kitty ]; then
        link_config "$source" "$target" kitty
    else
        unlink_config "$source" "$target" kitty
    fi

    # On Omarchy, also make it the default terminal (Super + Return)
    [ "$PLATFORM" = omarchy ] && [ "$terminal" != none ] || return 0
    if [ "$(current_terminal)" = "$terminal" ]; then
        echo "  ✓ $terminal is the default terminal"
    elif is_installed "$terminal"; then
        omarchy-default-terminal "$terminal"
        echo "  ✓ $terminal is now the default terminal"
    elif omarchy-install-terminal "$terminal"; then
        echo "  ✓ $terminal installed and set as the default terminal"
    else
        echo "  Could not install $terminal, keeping $(current_terminal)"
    fi
}

# ----------------------------
# LINKING
# ----------------------------

link_config() {
    local source="$1" target="$2" name="$3"

    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        echo "  ✓ $name already linked"
        return
    fi

    if [ -e "$target" ] || [ -L "$target" ]; then
        local backup="$target.bak.$(date +%Y%m%d-%H%M%S)"
        mv "$target" "$backup"
        echo "  Backed up $target -> $backup"
    fi

    mkdir -p "$(dirname "$target")"
    if ! ln -s "$source" "$target"; then
        [ "$PLATFORM" = windows ] && echo "  Enable Windows Developer Mode to allow symlinks, then run again."
        return 1
    fi
    echo "  ✓ $name -> $target"
}

# Remove our link and bring back the most recent backup, if any
unlink_config() {
    local source="$1" target="$2" name="$3"

    [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ] || return 0

    rm "$target"
    local backup
    backup="$(ls -d "$target".bak.* 2>/dev/null | sort | tail -1)"
    if [ -n "$backup" ]; then
        mv "$backup" "$target"
        echo "  - $name unlinked, restored $backup"
    else
        echo "  - $name unlinked"
    fi
}

ZSH_MARKER="# term-config"

install_zsh() {
    local extras="$1" zshrc="$2"

    if [ -f "$zshrc" ] && grep -q "zsh/extras.zsh" "$zshrc"; then
        echo "  ✓ zsh already sources extras.zsh"
    else
        printf '\n[ -f "%s" ] && source "%s" %s\n' "$extras" "$extras" "$ZSH_MARKER" >> "$zshrc"
        echo "  ✓ zsh: $zshrc now sources $extras"
    fi

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        read -r -n 1 -p "  Oh My Zsh not found. Install it? [y/N] " REPLY < /dev/tty
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # KEEP_ZSHRC keeps the line we just added
            KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
            echo "  Oh My Zsh installed!"
        fi
    fi
}

uninstall_zsh() {
    local zshrc="$2"

    [ -f "$zshrc" ] && grep -q "$ZSH_MARKER\$" "$zshrc" || return 0

    # Portable in-place edit (BSD and GNU sed differ on -i)
    grep -v "$ZSH_MARKER\$" "$zshrc" > "$zshrc.tmp" || true
    cat "$zshrc.tmp" > "$zshrc"
    rm "$zshrc.tmp"
    echo "  - zsh no longer sources extras.zsh"
}

install_tpm() {
    [ -d "$HOME/.tmux/plugins/tpm" ] && return
    read -r -n 1 -p "  Tmux Plugin Manager (tpm) not found. Install it? [y/N] " REPLY < /dev/tty
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
        echo "  tpm installed! Press prefix + I in tmux to install plugins."
    fi
}

# Older versions of this script linked tmux to ~/.tmux.conf. tmux loads that
# file *and* ~/.config/tmux/tmux.conf, so drop the old link.
unlink_config "$SCRIPT_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf" "old ~/.tmux.conf"

# WezTerm and Alacritty configs were removed from the repo; drop links to them
unlink_config "$SCRIPT_DIR/wezterm/.wezterm.lua" "$HOME/.wezterm.lua" "old WezTerm config"
unlink_config "$SCRIPT_DIR/alacritty" "$CONFIG_HOME/alacritty" "old Alacritty config"
[ "$PLATFORM" = windows ] && unlink_config "$SCRIPT_DIR/alacritty" "$(cygpath -u "$APPDATA")/alacritty" "old Alacritty config"

# ----------------------------
# CHOOSE
# ----------------------------

if [ ! -f "$CHOICES_FILE" ]; then
    RECONFIGURE=true
fi

CHOICES=""
while IFS='|' read -r name path target description; do
    [ -n "$name" ] || continue
    is_supported "$name" || continue

    choice="$(saved_choice "$name")"
    if [ "$RECONFIGURE" = true ] || [ -z "$choice" ]; then
        choice="$(ask "$name" "$description" "${choice:-$(default_choice "$name")}")"
    fi
    CHOICES="$CHOICES$name=$choice
"
done <<EOF
$COMPONENTS
EOF

TERMINAL_OPTIONS="$(terminal_options)"
if [ -n "$TERMINAL_OPTIONS" ]; then
    terminal="$(saved_choice terminal)"
    if [ "$RECONFIGURE" = true ] || [ -z "$terminal" ]; then
        terminal="$(ask_terminal "$TERMINAL_OPTIONS" "${terminal:-$(default_terminal "$TERMINAL_OPTIONS")}")"
    fi
    CHOICES="${CHOICES}terminal=$terminal
"
fi

mkdir -p "$(dirname "$CHOICES_FILE")"
printf '%s' "$CHOICES" > "$CHOICES_FILE"

# ----------------------------
# APPLY
# ----------------------------

echo
echo "Applying terminal configs..."

while IFS='|' read -r name path target description; do
    [ -n "$name" ] || continue
    is_supported "$name" || continue

    source="$SCRIPT_DIR/$path"
    if [ "$(saved_choice "$name")" = y ]; then
        case "$name" in
            zsh) install_zsh "$source" "$target" ;;
            tmux) link_config "$source" "$target" "$name" && install_tpm ;;
            *) link_config "$source" "$target" "$name" ;;
        esac
    else
        case "$name" in
            zsh) uninstall_zsh "$source" "$target" ;;
            *) unlink_config "$source" "$target" "$name" ;;
        esac
    fi
done <<EOF
$COMPONENTS
EOF

[ -n "$TERMINAL_OPTIONS" ] && apply_terminal "$(saved_choice terminal)"

echo
echo "Done! Choices saved to $CHOICES_FILE"
echo "Run ./install.sh --config to change them."
