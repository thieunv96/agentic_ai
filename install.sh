#!/usr/bin/env bash
# ML Framework Installer
# Installs the AI/ML development lifecycle framework into your project.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/thieunv96/agentic_ai/main/install.sh | bash
#   bash <(curl -fsSL https://raw.githubusercontent.com/thieunv96/agentic_ai/main/install.sh)
#
# Install to a custom directory (default: .github/):
#   curl -fsSL https://raw.githubusercontent.com/thieunv96/agentic_ai/main/install.sh | bash -s -- .my-ai
#
# Update an existing installation:
#   curl -fsSL https://raw.githubusercontent.com/thieunv96/agentic_ai/main/install.sh | bash

set -euo pipefail

REPO="thieunv96/agentic_ai"
BRANCH="main"
ARCHIVE_URL="https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz"
CLONE_URL="https://github.com/${REPO}.git"
TARGET_DIR=".github"
ML_SUBDIR="ml"   # source subdirectory inside the repo

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}[ml]${NC} $*"; }
success() { echo -e "${GREEN}[ml]${NC} $*"; }
warn()    { echo -e "${YELLOW}[ml]${NC} $*"; }
error()   { echo -e "${RED}[ml]${NC} $*" >&2; exit 1; }
step()    { echo -e "${CYAN}[ml]${NC} ${BOLD}$*${NC}"; }

# ── Parse arguments ───────────────────────────────────────────────────────────
if [ -n "${1:-}" ]; then
  TARGET_DIR="$1"
fi

# ── Check required tools ──────────────────────────────────────────────────────
command -v tar >/dev/null 2>&1 || error "Required tool not found: tar"

# ── Banner ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}  ML Framework Installer${NC}"
echo -e "  ${BLUE}github.com/${REPO}${NC}"
echo ""

# ── Detect existing installation ─────────────────────────────────────────────
UPDATING=false
if [ -f "${TARGET_DIR}/copilot-instructions.md" ]; then
  EXISTING_VERSION=""
  if [ -f "${TARGET_DIR}/ml/VERSION" ]; then
    EXISTING_VERSION=$(cat "${TARGET_DIR}/ml/VERSION")
  fi
  UPDATING=true
  info "Existing installation detected in ${TARGET_DIR}/${EXISTING_VERSION:+ (v${EXISTING_VERSION})} — updating ..."
else
  info "Installing ML framework into ${TARGET_DIR}/ ..."
fi

# ── Create temp directory ─────────────────────────────────────────────────────
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# ── Download repository ───────────────────────────────────────────────────────
DOWNLOADED=false

# Method 1: curl archive
if command -v curl >/dev/null 2>&1; then
  step "Downloading archive via curl ..."
  if curl -fsSL --connect-timeout 15 "$ARCHIVE_URL" -o "$TMP/archive.tar.gz" 2>/dev/null; then
    if tar -xz -C "$TMP" --strip-components=1 -f "$TMP/archive.tar.gz" 2>/dev/null; then
      DOWNLOADED=true
    fi
  fi
fi

# Method 2: wget archive
if [ "$DOWNLOADED" = false ] && command -v wget >/dev/null 2>&1; then
  step "Trying wget ..."
  if wget -q --timeout=15 "$ARCHIVE_URL" -O "$TMP/archive.tar.gz" 2>/dev/null; then
    if tar -xz -C "$TMP" --strip-components=1 -f "$TMP/archive.tar.gz" 2>/dev/null; then
      DOWNLOADED=true
    fi
  fi
fi

# Method 3: git clone (works even when raw.githubusercontent.com is blocked)
if [ "$DOWNLOADED" = false ] && command -v git >/dev/null 2>&1; then
  warn "Archive download failed — falling back to git clone ..."
  if git clone --depth=1 --quiet "$CLONE_URL" "$TMP/repo" 2>/dev/null; then
    # Flatten: move repo contents up to TMP
    cp -r "$TMP/repo/." "$TMP/"
    rm -rf "$TMP/repo"
    DOWNLOADED=true
  fi
fi

if [ "$DOWNLOADED" = false ]; then
  error "All download methods failed.\nEnsure curl, wget, or git is available and github.com is reachable."
fi

# ── Verify source structure ───────────────────────────────────────────────────
ML_SRC="$TMP/$ML_SUBDIR"
if [ ! -d "$ML_SRC" ]; then
  error "Expected '${ML_SUBDIR}/' directory not found in repo. Structure may have changed."
fi

if [ ! -f "$ML_SRC/copilot-instructions.md" ]; then
  error "Expected 'copilot-instructions.md' not found in ${ML_SUBDIR}/. Repository structure may have changed."
fi

# ── Read version ──────────────────────────────────────────────────────────────
NEW_VERSION=""
if [ -f "$ML_SRC/ml/VERSION" ]; then
  NEW_VERSION=$(cat "$ML_SRC/ml/VERSION")
fi

# ── Backup existing installation (if updating) ────────────────────────────────
if [ "$UPDATING" = true ]; then
  BACKUP_DIR="${TARGET_DIR}.bak.$(date +%Y%m%d%H%M%S)"
  info "Backing up existing installation to ${BACKUP_DIR}/ ..."
  cp -r "$TARGET_DIR" "$BACKUP_DIR"
fi

# ── Install ───────────────────────────────────────────────────────────────────
step "Installing framework files ..."

mkdir -p "$TARGET_DIR"

# Copy agents
if [ -d "$ML_SRC/agents" ]; then
  mkdir -p "$TARGET_DIR/agents"
  cp -r "$ML_SRC/agents/." "$TARGET_DIR/agents/"
  AGENT_COUNT=$(find "$TARGET_DIR/agents" -name "*.agent.md" | wc -l | tr -d ' ')
fi

# Copy skills
if [ -d "$ML_SRC/skills" ]; then
  mkdir -p "$TARGET_DIR/skills"
  cp -r "$ML_SRC/skills/." "$TARGET_DIR/skills/"
  SKILL_COUNT=$(find "$TARGET_DIR/skills" -name "*.md" | wc -l | tr -d ' ')
fi

# Copy hooks
if [ -d "$ML_SRC/hooks" ]; then
  mkdir -p "$TARGET_DIR/hooks"
  cp -r "$ML_SRC/hooks/." "$TARGET_DIR/hooks/"
fi

# Copy ml/ (workflows, templates, VERSION)
if [ -d "$ML_SRC/ml" ]; then
  mkdir -p "$TARGET_DIR/ml"
  cp -r "$ML_SRC/ml/." "$TARGET_DIR/ml/"
  WORKFLOW_COUNT=$(find "$TARGET_DIR/ml/workflows" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
fi

# Copy copilot-instructions.md
cp "$ML_SRC/copilot-instructions.md" "$TARGET_DIR/copilot-instructions.md"

# ── Verify installation ───────────────────────────────────────────────────────
ERRORS=0

[ -f "$TARGET_DIR/copilot-instructions.md" ] || { warn "Missing: copilot-instructions.md"; ERRORS=$((ERRORS+1)); }
[ -d "$TARGET_DIR/agents" ]                   || { warn "Missing: agents/"; ERRORS=$((ERRORS+1)); }
[ -d "$TARGET_DIR/skills" ]                   || { warn "Missing: skills/"; ERRORS=$((ERRORS+1)); }
[ -d "$TARGET_DIR/ml/workflows" ]             || { warn "Missing: ml/workflows/"; ERRORS=$((ERRORS+1)); }

if [ "$ERRORS" -gt 0 ]; then
  error "Installation incomplete — ${ERRORS} verification check(s) failed."
fi

# ── Success ───────────────────────────────────────────────────────────────────
echo ""
success "ML Framework ${NEW_VERSION:+v${NEW_VERSION} }installed into ${TARGET_DIR}/"
echo ""
echo -e "  ${BOLD}Components installed:${NC}"
echo -e "    ${GREEN}✓${NC} copilot-instructions.md"
echo -e "    ${GREEN}✓${NC} ${AGENT_COUNT:-?} agents  (${TARGET_DIR}/agents/)"
echo -e "    ${GREEN}✓${NC} ${SKILL_COUNT:-?} skills  (${TARGET_DIR}/skills/)"
echo -e "    ${GREEN}✓${NC} ${WORKFLOW_COUNT:-?} workflows  (${TARGET_DIR}/ml/workflows/)"
echo ""
echo -e "  ${BOLD}Next steps:${NC}"
echo ""
echo -e "  ${CYAN}1.${NC} Open your ML project in ${BOLD}Claude Code${NC}"
echo -e "     The ${TARGET_DIR}/ directory is auto-loaded as custom instructions."
echo ""
echo -e "  ${CYAN}2.${NC} Map your codebase (run once, or after major refactors):"
echo -e "     ${BOLD}/ml-map-codebase${NC}"
echo ""
echo -e "  ${CYAN}3.${NC} Start the development pipeline:"
echo -e "     ${BOLD}/ml-discuss 1${NC}   ← surface requirements for Phase 1"
echo -e "     ${BOLD}/ml-plan 1${NC}      ← break into tasks"
echo -e "     ${BOLD}/ml-implement 1${NC} ← build autonomously → test → docs → report"
echo ""
echo -e "  ${CYAN}4.${NC} Full command reference:"
echo -e "     ${BLUE}https://github.com/${REPO}${NC}"
echo ""

if [ "$UPDATING" = true ]; then
  info "Backup of previous installation: ${BACKUP_DIR}/"
  info "To restore: rm -rf ${TARGET_DIR}/ && mv ${BACKUP_DIR}/ ${TARGET_DIR}/"
fi
