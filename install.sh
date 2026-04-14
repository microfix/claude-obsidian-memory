#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════╗"
echo "║  Claude Code + Obsidian Memory System        ║"
echo "║  Persistent memory for Claude Code           ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Step 1: Get vault path
echo -e "${YELLOW}Step 1: Obsidian Vault Path${NC}"
echo ""
echo "Enter the full path to your Obsidian vault."
echo "Examples:"
echo "  macOS:  /Users/yourname/Documents/MyVault"
echo "  Linux:  /home/yourname/obsidian-vault"
echo ""
read -rp "Vault path: " VAULT_PATH

# Expand ~ if used
VAULT_PATH="${VAULT_PATH/#\~/$HOME}"

# Validate
if [ ! -d "$VAULT_PATH" ]; then
    echo -e "${RED}Error: Directory '$VAULT_PATH' does not exist.${NC}"
    echo "Create the vault in Obsidian first, then run this script again."
    exit 1
fi

echo -e "${GREEN}✓ Vault found at: $VAULT_PATH${NC}"
echo ""

# Step 2: Copy vault template
echo -e "${YELLOW}Step 2: Installing vault template${NC}"

if [ -d "$VAULT_PATH/AI" ]; then
    echo -e "${YELLOW}Warning: AI/ directory already exists in your vault.${NC}"
    read -rp "Overwrite? This will replace existing files. (y/N): " OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
        echo "Skipping vault template. Existing files preserved."
    else
        cp -r "$SCRIPT_DIR/vault/AI/" "$VAULT_PATH/AI/"
        echo -e "${GREEN}✓ AI/ directory updated${NC}"
    fi
else
    cp -r "$SCRIPT_DIR/vault/AI/" "$VAULT_PATH/AI/"
    echo -e "${GREEN}✓ AI/ directory created${NC}"
fi

# Copy skills
if [ -d "$VAULT_PATH/Claude Code/skills" ]; then
    echo -e "${YELLOW}Warning: Claude Code/skills/ already exists.${NC}"
    read -rp "Overwrite skills? (y/N): " OVERWRITE_SKILLS
    if [[ ! "$OVERWRITE_SKILLS" =~ ^[Yy]$ ]]; then
        echo "Skipping skills. Existing skills preserved."
    else
        cp -r "$SCRIPT_DIR/vault/Claude Code/" "$VAULT_PATH/Claude Code/"
        echo -e "${GREEN}✓ Skills updated${NC}"
    fi
else
    mkdir -p "$VAULT_PATH/Claude Code"
    cp -r "$SCRIPT_DIR/vault/Claude Code/" "$VAULT_PATH/Claude Code/"
    echo -e "${GREEN}✓ Skills installed${NC}"
fi

echo ""

# Step 3: Create symlinks
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

# Step 4: Install commands
echo -e "${YELLOW}Step 4: Installing commands${NC}"

mkdir -p ~/.claude/commands

for cmd in "$SCRIPT_DIR"/commands/*.md; do
    cp "$cmd" ~/.claude/commands/
    echo -e "${GREEN}  ✓ $(basename "$cmd")${NC}"
done

echo ""

# Step 5: Generate CLAUDE.md
echo -e "${YELLOW}Step 5: Setting up CLAUDE.md${NC}"

if [ -f ~/.claude/CLAUDE.md ]; then
    echo -e "${YELLOW}Warning: ~/.claude/CLAUDE.md already exists.${NC}"
    read -rp "Overwrite? (y/N): " OVERWRITE_CLAUDE
    if [[ ! "$OVERWRITE_CLAUDE" =~ ^[Yy]$ ]]; then
        echo "Skipping CLAUDE.md. You can manually merge from claude-md-template.md."
        echo ""
    else
        sed "s|<VAULT_PATH>|$VAULT_PATH|g" "$SCRIPT_DIR/claude-md-template.md" > ~/.claude/CLAUDE.md
        echo -e "${GREEN}✓ CLAUDE.md installed${NC}"
        echo ""
    fi
else
    sed "s|<VAULT_PATH>|$VAULT_PATH|g" "$SCRIPT_DIR/claude-md-template.md" > ~/.claude/CLAUDE.md
    echo -e "${GREEN}✓ CLAUDE.md installed${NC}"
    echo ""
fi

# Done
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
echo "  1. Edit $VAULT_PATH/AI/USER.md with your info"
echo "  2. Edit $VAULT_PATH/AI/SOUL.md with your preferences"
echo "  3. Open Claude Code — it will auto-read your memory"
echo ""
echo "Commands available:"
echo "  /compile  — Process raw notes inbox"
echo "  /audit    — Check memory health"
echo ""
echo -e "${BLUE}Happy building! 🚀${NC}"
