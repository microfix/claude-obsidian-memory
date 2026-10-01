#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

VAULT_PATH=""
AUTO_YES=false
USE_OBSIDIAN=true
SKILLS_MODE=""          # link | copy (default: link, copy on Windows)
EXTRA_SKILLS=""         # comma list, e.g. gdpr-check,icm-architect
ORGANIZED=false         # --organized: archive is organized by company (adds vault-organizer + single-source-of-truth rules)

print_usage() {
    echo "Usage: ./install.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --vault PATH        Folder that will contain AI/ (created if missing)"
    echo "  --yes               Auto-accept all prompts (non-interactive mode)"
    echo "  --no-obsidian       Plain Markdown folder: skip Obsidian install, Obsidian skills and rules"
    echo "  --skills-mode MODE  link (symlinks into the vault, default) or copy (cloud folders, Windows)"
    echo "  --skills LIST       Extra skills, comma separated: gdpr-check,icm-architect,vault-organizer"
    echo "  --organized         Archive will be organized by company: installs vault-organizer + vault-keeper, adds the single-source-of-truth block to CLAUDE.md"
    echo "  --help              Show this help message"
    echo ""
    echo "Core skills (always): skill-builder, memory-guard, anydoc, defuddle"
    echo "Obsidian skills (unless --no-obsidian): obsidian-markdown, obsidian-bases, obsidian-cli, json-canvas"
    echo ""
    echo "Examples:"
    echo "  ./install.sh                                              # Interactive"
    echo "  ./install.sh --vault ~/Documents/MyVault --yes            # New or existing Obsidian vault"
    echo "  ./install.sh --vault ~/Notes --yes --no-obsidian          # Plain folder"
    echo "  ./install.sh --vault \"\$HOME/OneDrive/Claude-Memory\" --yes --skills-mode copy --skills gdpr-check"
    echo ""
    echo "Run the onboarding interview first if you are unsure which options fit: see INTERVIEW.md"
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --vault) VAULT_PATH="$2"; shift 2 ;;
        --yes|-y) AUTO_YES=true; shift ;;
        --no-obsidian) USE_OBSIDIAN=false; shift ;;
        --skills-mode) SKILLS_MODE="$2"; shift 2 ;;
        --skills) EXTRA_SKILLS="$2"; shift 2 ;;
        --organized) ORGANIZED=true; shift ;;
        --help|-h) print_usage; exit 0 ;;
        *) echo -e "${RED}Unknown option: $1${NC}"; print_usage; exit 1 ;;
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

if [ -z "$SKILLS_MODE" ]; then
    case "$OS" in
        MINGW*|MSYS*|CYGWIN*) SKILLS_MODE="copy" ;;
        *) SKILLS_MODE="link" ;;
    esac
fi
if [ "$SKILLS_MODE" != "link" ] && [ "$SKILLS_MODE" != "copy" ]; then
    echo -e "${RED}--skills-mode must be 'link' or 'copy'${NC}"
    exit 1
fi

# Skill selection
SKILLS=("skill-builder" "memory-guard" "anydoc" "defuddle")
if [ "$ORGANIZED" = true ]; then
    SKILLS+=("vault-organizer" "vault-keeper")
fi
if [ "$USE_OBSIDIAN" = true ]; then
    SKILLS+=("obsidian-markdown" "obsidian-bases" "obsidian-cli" "json-canvas")
fi
if [ -n "$EXTRA_SKILLS" ]; then
    IFS=',' read -ra EXTRA <<< "$EXTRA_SKILLS"
    for s in "${EXTRA[@]}"; do
        s="$(echo "$s" | tr -d ' ')"
        if { [ "$s" = "vault-organizer" ] || [ "$s" = "vault-keeper" ]; } && [ "$ORGANIZED" = true ]; then continue; fi
        if [ -d "$SCRIPT_DIR/vault/Claude Code/skills/$s" ]; then
            SKILLS+=("$s")
        else
            echo -e "${YELLOW}Unknown skill '$s', skipping.${NC}"
        fi
    done
fi

# ──────────────────────────────────────────────
# Step 0: Check and install Obsidian if needed
# ──────────────────────────────────────────────
echo -e "${YELLOW}Step 0: Checking for Obsidian${NC}"

if [ "$USE_OBSIDIAN" = false ]; then
    echo "  --no-obsidian: plain Markdown folder, skipping Obsidian."
else
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
                echo -e "${YELLOW}Homebrew not found, so Obsidian is not installed automatically.${NC}"
                echo "  Download it from https://obsidian.md/ (free) and drag it to Applications. Continuing: the memory works without it."
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
                echo -e "${YELLOW}No supported package manager found (snap/flatpak).${NC}"
                echo "  Install Obsidian from https://obsidian.md/ . Continuing: the memory works without it."
            fi
        else
            echo -e "${YELLOW}Cannot auto-install Obsidian on $OS. Install it from https://obsidian.md/${NC}"
            echo "Continuing: the memory works without it."
        fi
    fi
fi

echo ""

# ──────────────────────────────────────────────
# Step 1: Get or create vault
# ──────────────────────────────────────────────
echo -e "${YELLOW}Step 1: Memory folder${NC}"

if [ -n "$VAULT_PATH" ]; then
    VAULT_PATH="${VAULT_PATH/#\~/$HOME}"
fi

if [ -z "$VAULT_PATH" ]; then
    echo ""
    echo "Enter the full path of the folder that should hold the memory."
    echo "An existing Obsidian vault or notes folder is fine: only AI/ and Claude Code/ are added."
    echo "If it doesn't exist yet, we'll create it."
    echo ""
    read -rp "Folder path: " VAULT_PATH
    VAULT_PATH="${VAULT_PATH/#\~/$HOME}"
fi

if [ -z "$VAULT_PATH" ]; then
    echo -e "${RED}Error: No folder path provided.${NC}"
    exit 1
fi

if [ ! -d "$VAULT_PATH" ]; then
    echo -e "${YELLOW}Directory '$VAULT_PATH' does not exist.${NC}"
    if confirm "Create it?"; then
        mkdir -p "$VAULT_PATH"
        if [ "$USE_OBSIDIAN" = true ]; then
            mkdir -p "$VAULT_PATH/.obsidian"
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
            echo -e "${GREEN}✓ Folder created at: $VAULT_PATH${NC}"
        fi
    else
        echo "Create the folder first, then run this script again."
        exit 1
    fi
else
    echo -e "${GREEN}✓ Folder found at: $VAULT_PATH${NC}"
    echo "  Existing files are never moved, renamed or deleted."
fi

echo ""

# ──────────────────────────────────────────────
# Step 2: Copy memory structure and skills
# ──────────────────────────────────────────────
echo -e "${YELLOW}Step 2: Installing memory structure${NC}"

# Merge without overwriting: files that already exist are kept.
merge_copy() {
    mkdir -p "$2"
    cp -Rn "$1/." "$2/" 2>/dev/null || cp -R "$1/." "$2/"
}

if [ -d "$VAULT_PATH/AI" ]; then
    echo -e "${YELLOW}AI/ already exists in this folder.${NC}"
    if confirm "Merge the template into it? (existing files are kept, only missing ones are added)"; then
        merge_copy "$SCRIPT_DIR/vault/AI" "$VAULT_PATH/AI"
        echo -e "${GREEN}✓ AI/ merged${NC}"
    else
        echo "Skipping memory template. Existing files preserved."
    fi
else
    merge_copy "$SCRIPT_DIR/vault/AI" "$VAULT_PATH/AI"
    echo -e "${GREEN}✓ AI/ created${NC}"
fi

mkdir -p "$VAULT_PATH/Claude Code/skills"
for skill in "${SKILLS[@]}"; do
    if [ -d "$VAULT_PATH/Claude Code/skills/$skill" ]; then
        echo "  = $skill already in vault, kept"
    else
        cp -R "$SCRIPT_DIR/vault/Claude Code/skills/$skill" "$VAULT_PATH/Claude Code/skills/$skill"
        echo -e "${GREEN}  ✓ $skill${NC}"
    fi
done

echo ""

# ──────────────────────────────────────────────
# Step 3: Install skills into ~/.claude/skills
# ──────────────────────────────────────────────
echo -e "${YELLOW}Step 3: Installing skills ($SKILLS_MODE)${NC}"

mkdir -p ~/.claude/skills

for skill in "${SKILLS[@]}"; do
    SOURCE="$VAULT_PATH/Claude Code/skills/$skill"
    TARGET="$HOME/.claude/skills/$skill"

    if [ -L "$TARGET" ]; then
        rm "$TARGET"
    elif [ -d "$TARGET" ]; then
        echo -e "${YELLOW}  Warning: $TARGET is a real directory. Skipping.${NC}"
        continue
    fi

    if [ "$SKILLS_MODE" = "link" ]; then
        ln -sf "$SOURCE" "$TARGET"
        echo -e "${GREEN}  ✓ $skill → vault${NC}"
    else
        cp -R "$SOURCE" "$TARGET"
        echo -e "${GREEN}  ✓ $skill (copied)${NC}"
    fi
done

if [ "$SKILLS_MODE" = "copy" ]; then
    echo -e "${YELLOW}  Copy mode: edits to a skill in the vault do not reach ~/.claude/skills automatically. Re-run this script to refresh.${NC}"
fi

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

render_claude_md() {
    local tmp
    tmp="$(mktemp)"
    # Conditional blocks: keep (drop marker lines) or remove entirely
    cp "$SCRIPT_DIR/claude-md-template.md" "$tmp"
    if [ "$USE_OBSIDIAN" = true ]; then
        sed -i.bak -e '/<!-- IF:OBSIDIAN -->/d' -e '/<!-- ENDIF:OBSIDIAN -->/d' "$tmp"
    else
        sed -i.bak -e '/<!-- IF:OBSIDIAN -->/,/<!-- ENDIF:OBSIDIAN -->/d' "$tmp"
    fi
    if [ "$ORGANIZED" = true ]; then
        sed -i.bak -e '/<!-- IF:ORGANIZED -->/d' -e '/<!-- ENDIF:ORGANIZED -->/d' "$tmp"
    else
        sed -i.bak -e '/<!-- IF:ORGANIZED -->/,/<!-- ENDIF:ORGANIZED -->/d' "$tmp"
    fi
    rm -f "$tmp.bak"
    # Extra skill rows (awk, because the rows contain | characters)
    local extra=""
    case ",$EXTRA_SKILLS," in *,gdpr-check,*) extra="${extra}| Feature or flow touches personal data, login, cookies, tracking, consent | \`gdpr-check\` |"$'\n' ;; esac
    if [ "$ORGANIZED" = true ]; then extra="${extra}| Organize, index or clean up an existing archive; split files by company | \`vault-organizer\` |"$'\n'"| Read or write the shared company archive, save a document or note for the company | \`vault-keeper\` |"$'\n'; fi
    case ",$EXTRA_SKILLS," in *,icm-architect,*) extra="${extra}| Repeated multi-step flow, \"organize this for agents\", team knowledge base | \`icm-architect\` |"$'\n' ;; esac
    EXTRA_ROWS="$extra" VAULT="$VAULT_PATH" awk '
        /<!-- SKILLS:EXTRA -->/ { printf "%s", ENVIRON["EXTRA_ROWS"]; next }
        { line = $0; out = ""
          while ((i = index(line, "<VAULT_PATH>")) > 0) { out = out substr(line, 1, i-1) ENVIRON["VAULT"]; line = substr(line, i+12) }
          print out line }
    ' "$tmp"
    rm -f "$tmp"
}

if [ -f ~/.claude/CLAUDE.md ]; then
    echo -e "${YELLOW}Warning: ~/.claude/CLAUDE.md already exists.${NC}"
    if confirm "Overwrite? (a backup is saved as CLAUDE.md.bak)"; then
        cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.bak
        render_claude_md > ~/.claude/CLAUDE.md
        echo -e "${GREEN}✓ CLAUDE.md installed (old one kept as CLAUDE.md.bak)${NC}"
    else
        echo "Skipping CLAUDE.md. Merge the sections from claude-md-template.md by hand."
    fi
else
    render_claude_md > ~/.claude/CLAUDE.md
    echo -e "${GREEN}✓ CLAUDE.md installed${NC}"
fi

echo ""

# ──────────────────────────────────────────────
# Step 6: Optional CLIs
# ──────────────────────────────────────────────
echo -e "${YELLOW}Step 6: Optional dependencies${NC}"

install_npm_tool() {
    local cmd="$1" pkg="$2" desc="$3"
    if command -v "$cmd" &>/dev/null; then
        echo -e "${GREEN}✓ $cmd already installed${NC}"
    elif command -v npm &>/dev/null; then
        echo "$desc"
        if confirm "Install $cmd globally via npm?"; then
            npm install -g "$pkg" 2>/dev/null && echo -e "${GREEN}✓ $cmd installed${NC}" || echo -e "${YELLOW}  $cmd install failed (non-critical). Install manually: npm install -g $pkg${NC}"
        else
            echo "  Skipped. Install later: npm install -g $pkg"
        fi
    else
        echo "  npm not found. The $cmd skill requires: npm install -g $pkg"
    fi
}

install_npm_tool anydoc @firecrawl/anydoc "anydoc converts documents (PDF, Word, Excel, PowerPoint...) to markdown (used by the anydoc skill)."
install_npm_tool defuddle defuddle "Defuddle extracts clean content from web pages (used by the defuddle skill)."

if [ "$USE_OBSIDIAN" = true ]; then
    if command -v obsidian &>/dev/null; then
        echo -e "${GREEN}✓ Obsidian CLI already installed${NC}"
    else
        echo "  Obsidian CLI not found. The obsidian-cli skill requires it."
        echo "  Install via Obsidian Settings → General → Enable CLI"
    fi
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
echo "  📁 $VAULT_PATH/Claude Code/ — Skills (${SKILLS[*]})"
echo "  🔗 ~/.claude/skills/         — Skills ($SKILLS_MODE)"
echo "  📄 ~/.claude/commands/        — /compile and /audit"
echo "  📄 ~/.claude/CLAUDE.md        — Global instructions"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Fill in $VAULT_PATH/AI/SETUP-PROFILE.md and USER.md (or let Claude run the interview: see INTERVIEW.md)"
if [ "$USE_OBSIDIAN" = true ]; then
echo "  2. Open the folder in Obsidian (if not already)"
echo "  3. Start Claude Code, it will auto-read your memory"
else
echo "  2. Start Claude Code, it will auto-read your memory"
fi
echo ""
echo "Anthropic's document skills (docx, xlsx, pptx, pdf) are installed separately:"
echo "  /plugin marketplace add anthropics/skills"
echo "  /plugin install document-skills@anthropic-agent-skills"
echo ""
echo -e "${BLUE}Happy building!${NC}"
