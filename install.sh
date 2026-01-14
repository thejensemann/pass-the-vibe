#!/usr/bin/env bash
#
# pass-the-vibe installer
# Usage: curl -fsSL https://raw.githubusercontent.com/thejensemann/pass-the-vibe/main/install.sh | bash
#
set -euo pipefail

INSTALL_DIR="${PASS_THE_VIBE_DIR:-$HOME/.pass-the-vibe}"
REPO_URL="https://github.com/thejensemann/pass-the-vibe.git"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}==>${NC} $1"; }
success() { echo -e "${GREEN}==>${NC} $1"; }
warn() { echo -e "${YELLOW}==>${NC} $1"; }
error() { echo -e "${RED}==>${NC} $1"; }

echo ""
echo "  pass-the-vibe installer"
echo "  Auto-document your Claude Code sessions"
echo ""

# Check for git
if ! command -v git &> /dev/null; then
    error "git is required but not installed."
    exit 1
fi

# Check for jq (recommended)
if ! command -v jq &> /dev/null; then
    warn "jq is not installed (recommended for merging with existing Claude settings)"
    echo ""
    echo "    Install jq:"
    echo ""
    case "$(uname -s)" in
        Darwin*)
            echo "      brew install jq"
            ;;
        Linux*)
            if command -v apt-get &> /dev/null; then
                echo "      sudo apt-get install jq"
            elif command -v dnf &> /dev/null; then
                echo "      sudo dnf install jq"
            elif command -v pacman &> /dev/null; then
                echo "      sudo pacman -S jq"
            else
                echo "      # Use your package manager to install jq"
            fi
            ;;
        *)
            echo "      # See https://jqlang.github.io/jq/download/"
            ;;
    esac
    echo ""
    echo "    Continuing without jq..."
    echo ""
fi

# Clone or update
if [[ -d "$INSTALL_DIR" ]]; then
    info "Updating existing installation..."
    cd "$INSTALL_DIR"
    git pull --quiet origin main
else
    info "Installing to $INSTALL_DIR..."
    git clone --quiet "$REPO_URL" "$INSTALL_DIR"
fi

# Make executable
chmod +x "$INSTALL_DIR/pass-the-vibe"
chmod +x "$INSTALL_DIR/hooks/"*.sh

success "Installed successfully!"
echo ""

# Detect shell and suggest PATH addition
SHELL_NAME=$(basename "$SHELL")
SHELL_RC=""

case "$SHELL_NAME" in
    bash)
        if [[ -f "$HOME/.bash_profile" ]]; then
            SHELL_RC="$HOME/.bash_profile"
        else
            SHELL_RC="$HOME/.bashrc"
        fi
        ;;
    zsh)
        SHELL_RC="$HOME/.zshrc"
        ;;
    fish)
        SHELL_RC="$HOME/.config/fish/config.fish"
        ;;
esac

# Check if already in PATH
if [[ ":$PATH:" == *":$INSTALL_DIR:"* ]]; then
    success "pass-the-vibe is already in your PATH"
else
    echo "  Add to your PATH by running:"
    echo ""
    if [[ "$SHELL_NAME" == "fish" ]]; then
        echo "    fish_add_path $INSTALL_DIR"
    else
        echo "    echo 'export PATH=\"\$PATH:$INSTALL_DIR\"' >> $SHELL_RC"
        echo "    source $SHELL_RC"
    fi
    echo ""
    echo "  Or run directly:"
    echo ""
    echo "    $INSTALL_DIR/pass-the-vibe init"
fi

echo ""
echo "  Usage:"
echo ""
echo "    cd your-project"
echo "    pass-the-vibe init"
echo ""
