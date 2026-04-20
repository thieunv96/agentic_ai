#!/usr/bin/env bash
# AI/ML Framework Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/thieunv96/agentic_ai/main/install.sh | bash

set -euo pipefail

REPO="thieunv96/agentic_ai"
BRANCH="main"
ARCHIVE_URL="https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz"
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
for cmd in curl tar; do
  command -v "$cmd" >/dev/null 2>&1 || error "Required tool not found: $cmd"
done

# Determine install destination
if [ -n "${1:-}" ]; then
  TARGET_DIR="$1"
fi

info "Installing AI/ML framework into ${TARGET_DIR}/ ..."

# Create temp directory
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# Download archive
info "Downloading from ${REPO}..."
if ! curl -fsSL "$ARCHIVE_URL" -o "$TMP/archive.tar.gz"; then
  error "Download failed. Check your internet connection or repository URL."
fi

# Extract — strip the top-level repo directory
tar -xz -C "$TMP" --strip-components=1 -f "$TMP/archive.tar.gz"

# Verify ai/ directory exists in archive
if [ ! -d "$TMP/ai" ]; then
  error "Expected 'ai/' directory not found in archive. Repository structure may have changed."
fi

# Read version
VERSION=""
if [ -f "$TMP/ai/my/VERSION" ]; then
  VERSION=$(cat "$TMP/ai/my/VERSION")
fi

# Create target directory
mkdir -p "$TARGET_DIR"

# Copy framework files
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
