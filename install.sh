#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments for non-interactive mode
VAULT_PATH=""
AUTO_YES=false
INSTALL_OBSIDIAN=false

print_usage() {
    echo "Usage: ./install.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --vault PATH    Path to Obsidian vault (skips interactive prompt)"
    echo "  --yes           Auto-accept all prompts (non-interactive mode)"
    echo "  --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./install.sh                              # Interactive mode"
    echo "  ./install.sh --vault ~/my-vault --yes     # Non-interactive (for Claude Code)"
    echo "  ./install.sh --vault ~/my-vault           # Set vault, confirm prompts interactively"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --vault)
            VAULT_PATH="$2"
            shift 2
            ;;
        --yes|-y)
            AUTO_YES=true
            shift
            ;;
        --help|-h)
            print_usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            print_usage
            exit 1
            ;;
    esac
done

confirm() {
    if [ "$AUTO_YES" = true ]; then
        return 0
    fi
    read -rp "$1 (y/N): " response
    [[ "$response" =~ ^[Yy]$ ]]
}

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════╗"
echo "║  Claude Code + Obsidian Memory System        ║"
echo "║  Persistent memory for Claude Code           ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

# ──────────────────────────────────────────────
# Step 0: Check and install Obsidian if needed
# ──────────────────────────────────────────────
echo -e "${YELLOW}Step 0: Checking for Obsidian${NC}"

OBSIDIAN_INSTALLED=false

if [ "$OS" = "Darwin" ]; then
    if [ -d "/Applications/Obsidian.app" ] || [ -d "$HOME/Applications/Obsidian.app" ]; then
        OBSIDIAN_INSTALLED=true
    fi
elif [ "$OS" = "Linux" ]; then
    if command -v obsidian &>/dev/null || snap list obsidian &>/dev/null 2>&1 || flatpak list 2>/dev/null | grep -q obsidian; then
        OBSIDIAN_INSTALLED=true
    fi
fi

if [ "$OBSIDIAN_INSTALLED" = true ]; then
    echo -e "${GREEN}✓ Obsidian is installed${NC}"
else
    echo -e "${YELLOW}Obsidian is not installed.${NC}"

    if [ "$OS" = "Darwin" ]; then
        if command -v brew &>/dev/null; then
            echo "Installing Obsidian via Homebrew..."
            brew install --cask obsidian
            echo -e "${GREEN}✓ Obsidian installed${NC}"
        else
            echo -e "${RED}Homebrew not found. Install Obsidian manually from https://obsidian.md/${NC}"
            echo "Then run this script again."
            exit 1
        fi
    elif [ "$OS" = "Linux" ]; then
        if command -v snap &>/dev/null; then
            echo "Installing Obsidian via Snap..."
            sudo snap install obsidian --classic
            echo -e "${GREEN}✓ Obsidian installed via Snap${NC}"
        elif command -v flatpak &>/dev/null; then
            echo "Installing Obsidian via Flatpak..."
            flatpak install -y flathub md.obsidian.Obsidian
            echo -e "${GREEN}✓ Obsidian installed via Flatpak${NC}"
        else
            echo -e "${RED}No supported package manager found (snap/flatpak).${NC}"
            echo "Install Obsidian manually from https://obsidian.md/"
            echo "Then run this script again."
            exit 1
        fi
    else
        echo -e "${RED}Unsupported OS: $OS${NC}"
        echo "Install Obsidian manually from https://obsidian.md/"
        exit 1
    fi
fi

echo ""

# ──────────────────────────────────────────────
# Step 1: Get or create vault
# ──────────────────────────────────────────────
echo -e "${YELLOW}Step 1: Obsidian Vault${NC}"

# Expand ~ if used
if [ -n "$VAULT_PATH" ]; then
    VAULT_PATH="${VAULT_PATH/#\~/$HOME}"
fi

if [ -z "$VAULT_PATH" ]; then
    echo ""
    echo "Enter the full path to your Obsidian vault."
    echo "If it doesn't exist yet, we'll create it for you."
    echo ""
    echo "Examples:"
    echo "  macOS:  ~/Documents/MyVault"
    echo "  Linux:  ~/obsidian-vault"
    echo ""
    read -rp "Vault path: " VAULT_PATH
    VAULT_PATH="${VAULT_PATH/#\~/$HOME}"
fi

if [ -z "$VAULT_PATH" ]; then
    echo -e "${RED}Error: No vault path provided.${NC}"
    exit 1
fi

if [ ! -d "$VAULT_PATH" ]; then
    echo -e "${YELLOW}Directory '$VAULT_PATH' does not exist.${NC}"
    if confirm "Create it as a new Obsidian vault?"; then
        mkdir -p "$VAULT_PATH"
        # Create .obsidian directory to make it a valid vault
        mkdir -p "$VAULT_PATH/.obsidian"
        # Minimal Obsidian config
        cat > "$VAULT_PATH/.obsidian/app.json" << 'OBSIDIAN_CONFIG'
{
  "useMarkdownLinks": false,
  "newLinkFormat": "shortest",
  "showFrontmatter": true,
  "strictLineBreaks": false,
  "readableLineLength": true
}
OBSIDIAN_CONFIG
        echo -e "${GREEN}✓ Vault created at: $VAULT_PATH${NC}"
        echo -e "${YELLOW}  Open this folder in Obsidian to complete vault setup.${NC}"
    else
        echo "Create a vault in Obsidian first, then run this script again."
        exit 1
    fi
else
    echo -e "${GREEN}✓ Vault found at: $VAULT_PATH${NC}"
fi

echo ""

# ──────────────────────────────────────────────
# Step 2: Copy vault template
# ──────────────────────────────────────────────
echo -e "${YELLOW}Step 2: Installing vault template${NC}"

if [ -d "$VAULT_PATH/AI" ]; then
    echo -e "${YELLOW}Warning: AI/ directory already exists in your vault.${NC}"
    if confirm "Overwrite? This will replace existing files."; then
        cp -r "$SCRIPT_DIR/vault/AI/" "$VAULT_PATH/AI/"
        echo -e "${GREEN}✓ AI/ directory updated${NC}"
    else
        echo "Skipping vault template. Existing files preserved."
    fi
else
    cp -r "$SCRIPT_DIR/vault/AI/" "$VAULT_PATH/AI/"
    echo -e "${GREEN}✓ AI/ directory created${NC}"
fi

# Copy skills
if [ -d "$VAULT_PATH/Claude Code/skills" ]; then
    echo -e "${YELLOW}Warning: Claude Code/skills/ already exists.${NC}"
    if confirm "Overwrite skills?"; then
        cp -r "$SCRIPT_DIR/vault/Claude Code/" "$VAULT_PATH/Claude Code/"
        echo -e "${GREEN}✓ Skills updated${NC}"
    else
        echo "Skipping skills. Existing skills preserved."
    fi
else
    mkdir -p "$VAULT_PATH/Claude Code"
    cp -r "$SCRIPT_DIR/vault/Claude Code/" "$VAULT_PATH/Claude Code/"
    echo -e "${GREEN}✓ Skills installed${NC}"
fi

echo ""

# ──────────────────────────────────────────────
# Step 3: Create symlinks
# ──────────────────────────────────────────────
echo -e "${YELLOW}Step 3: Creating skill symlinks${NC}"

mkdir -p ~/.claude/skills

SKILLS=("skill-builder" "obsidian-markdown" "obsidian-bases" "obsidian-cli" "defuddle")

for skill in "${SKILLS[@]}"; do
    SOURCE="$VAULT_PATH/Claude Code/skills/$skill"
    TARGET="$HOME/.claude/skills/$skill"

    if [ -L "$TARGET" ]; then
        rm "$TARGET"
    elif [ -d "$TARGET" ]; then
        echo -e "${YELLOW}  Warning: $TARGET is a directory (not symlink). Skipping.${NC}"
        continue
    fi

    ln -sf "$SOURCE" "$TARGET"
    echo -e "${GREEN}  ✓ $skill → vault${NC}"
done

echo ""

# ──────────────────────────────────────────────
# Step 4: Install commands
# ──────────────────────────────────────────────
echo -e "${YELLOW}Step 4: Installing commands${NC}"

mkdir -p ~/.claude/commands

for cmd in "$SCRIPT_DIR"/commands/*.md; do
    cp "$cmd" ~/.claude/commands/
    echo -e "${GREEN}  ✓ $(basename "$cmd")${NC}"
done

echo ""

# ──────────────────────────────────────────────
# Step 5: Generate CLAUDE.md
# ──────────────────────────────────────────────
echo -e "${YELLOW}Step 5: Setting up CLAUDE.md${NC}"

if [ -f ~/.claude/CLAUDE.md ]; then
    echo -e "${YELLOW}Warning: ~/.claude/CLAUDE.md already exists.${NC}"
    if confirm "Overwrite?"; then
        sed "s|<VAULT_PATH>|$VAULT_PATH|g" "$SCRIPT_DIR/claude-md-template.md" > ~/.claude/CLAUDE.md
        echo -e "${GREEN}✓ CLAUDE.md installed${NC}"
    else
        echo "Skipping CLAUDE.md. You can manually merge from claude-md-template.md."
    fi
else
    sed "s|<VAULT_PATH>|$VAULT_PATH|g" "$SCRIPT_DIR/claude-md-template.md" > ~/.claude/CLAUDE.md
    echo -e "${GREEN}✓ CLAUDE.md installed${NC}"
fi

echo ""

# ──────────────────────────────────────────────
# Step 6: Install Defuddle CLI (optional)
# ──────────────────────────────────────────────
echo -e "${YELLOW}Step 6: Optional dependencies${NC}"

if command -v defuddle &>/dev/null; then
    echo -e "${GREEN}✓ Defuddle CLI already installed${NC}"
else
    if command -v npm &>/dev/null; then
        echo "Defuddle CLI extracts clean content from web pages (used by the defuddle skill)."
        if confirm "Install defuddle globally via npm?"; then
            npm install -g defuddle 2>/dev/null && echo -e "${GREEN}✓ Defuddle installed${NC}" || echo -e "${YELLOW}  Defuddle install failed (non-critical). Install manually: npm install -g defuddle${NC}"
        else
            echo "  Skipped. Install later: npm install -g defuddle"
        fi
    else
        echo "  npm not found. Defuddle skill requires: npm install -g defuddle"
    fi
fi

if command -v obsidian &>/dev/null; then
    echo -e "${GREEN}✓ Obsidian CLI already installed${NC}"
else
    echo "  Obsidian CLI not found. The obsidian-cli skill requires it."
    echo "  Install via Obsidian Settings → General → Enable CLI"
fi

echo ""

# ──────────────────────────────────────────────
# Done
# ──────────────────────────────────────────────
echo -e "${BLUE}══════════════════════════════════════════════${NC}"
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "What's installed:"
echo "  📁 $VAULT_PATH/AI/          — Memory structure"
echo "  📁 $VAULT_PATH/Claude Code/ — Skills"
echo "  🔗 ~/.claude/skills/         — Symlinks to vault"
echo "  📄 ~/.claude/commands/        — /compile and /audit"
echo "  📄 ~/.claude/CLAUDE.md        — Global instructions"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Open the vault folder in Obsidian (if not already)"
echo "  2. Edit $VAULT_PATH/AI/USER.md with your info"
echo "  3. Edit $VAULT_PATH/AI/SOUL.md with your preferences"
echo "  4. Start Claude Code — it will auto-read your memory"
echo ""
echo "Commands available in Claude Code:"
echo "  /compile  — Process raw notes inbox"
echo "  /audit    — Check memory health"
echo ""
echo -e "${BLUE}Happy building!${NC}"
