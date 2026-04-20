#!/usr/bin/env bash
# AI/ML Framework Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/thieunv96/agentic_ai/main/install.sh | bash
# Or:    bash <(curl -fsSL https://github.com/thieunv96/agentic_ai/raw/main/install.sh)

set -euo pipefail

REPO="thieunv96/agentic_ai"
BRANCH="main"
ARCHIVE_URL="https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz"
CLONE_URL="https://github.com/${REPO}.git"
TARGET_DIR=".github"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[ai]${NC} $*"; }
success() { echo -e "${GREEN}[ai]${NC} $*"; }
warn()    { echo -e "${YELLOW}[ai]${NC} $*"; }
error()   { echo -e "${RED}[ai]${NC} $*" >&2; exit 1; }

# Check for required tools
command -v tar >/dev/null 2>&1 || error "Required tool not found: tar"

# Determine install destination
if [ -n "${1:-}" ]; then
  TARGET_DIR="$1"
fi

info "Installing AI/ML framework into ${TARGET_DIR}/ ..."

# Create temp directory
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# Try method 1: curl archive download
DOWNLOADED=false
if command -v curl >/dev/null 2>&1; then
  info "Downloading archive from github.com ..."
  if curl -fsSL "$ARCHIVE_URL" -o "$TMP/archive.tar.gz" 2>/dev/null; then
    tar -xz -C "$TMP" --strip-components=1 -f "$TMP/archive.tar.gz" 2>/dev/null && DOWNLOADED=true
  fi
fi

# Try method 2: wget archive download
if [ "$DOWNLOADED" = false ] && command -v wget >/dev/null 2>&1; then
  info "Trying wget ..."
  if wget -q "$ARCHIVE_URL" -O "$TMP/archive.tar.gz" 2>/dev/null; then
    tar -xz -C "$TMP" --strip-components=1 -f "$TMP/archive.tar.gz" 2>/dev/null && DOWNLOADED=true
  fi
fi

# Try method 3: git clone (most compatible, works even if raw.githubusercontent.com is blocked)
if [ "$DOWNLOADED" = false ] && command -v git >/dev/null 2>&1; then
  warn "Archive download failed — falling back to git clone ..."
  if git clone --depth=1 "$CLONE_URL" "$TMP/repo" 2>/dev/null; then
    cp -r "$TMP/repo/"* "$TMP/"
    DOWNLOADED=true
  fi
fi

if [ "$DOWNLOADED" = false ]; then
  error "All download methods failed. Ensure git, curl, or wget is available and github.com is accessible."
fi

# Verify ai/ directory exists
if [ ! -d "$TMP/ai" ]; then
  error "Expected 'ai/' directory not found. Repository structure may have changed."
fi

# Read version
VERSION=""
if [ -f "$TMP/ai/my/VERSION" ]; then
  VERSION=$(cat "$TMP/ai/my/VERSION")
fi

# Create target directory and copy
mkdir -p "$TARGET_DIR"
cp -r "$TMP/ai/"* "$TARGET_DIR/"

# Verify installation
if [ ! -f "$TARGET_DIR/copilot-instructions.md" ]; then
  error "Installation incomplete — copilot-instructions.md not found in ${TARGET_DIR}/"
fi

VERSION_DISPLAY="${VERSION:+v${VERSION}}"
success "Framework ${VERSION_DISPLAY} installed into ${TARGET_DIR}/"
echo ""
echo "  Next steps:"
echo "  1. Open your project in Claude Code (or GitHub Copilot)"
echo "  2. The .github/ directory is auto-loaded as custom instructions"
echo "  3. Run /my-new-version to start your first version"
echo ""
