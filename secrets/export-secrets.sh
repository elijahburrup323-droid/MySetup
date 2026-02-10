#!/usr/bin/env bash
# =============================================================================
# Export secrets from current machine for transfer to a new PC
# =============================================================================
# Usage:
#   bash secrets/export-secrets.sh              (encrypted with GPG)
#   bash secrets/export-secrets.sh --plain      (unencrypted, for quick transfer)
#
# Run this on your CURRENT working machine BEFORE setting up the new one.
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECTS_DIR="/c/Projects"
SECRETS_FILE="$SCRIPT_DIR/secrets.env"
ENCRYPTED_FILE="$SCRIPT_DIR/secrets.env.gpg"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
info() { echo -e "${CYAN}[i]${NC} $1"; }

echo ""
echo "=== MySetup Secrets Exporter ==="
echo ""

# Collect secrets from ExpenseTracker
if [ -f "$PROJECTS_DIR/ExpenseTracker/.env" ]; then
  info "Reading secrets from ExpenseTracker/.env..."
  cp "$PROJECTS_DIR/ExpenseTracker/.env" "$SECRETS_FILE"
  log "Secrets copied to $SECRETS_FILE"
else
  warn "No .env file found at $PROJECTS_DIR/ExpenseTracker/.env"
  warn "Creating template from .env.example..."
  if [ -f "$PROJECTS_DIR/ExpenseTracker/.env.example" ]; then
    cp "$PROJECTS_DIR/ExpenseTracker/.env.example" "$SECRETS_FILE"
    warn "Template copied — you'll need to fill in the actual values"
  else
    echo "# ExpenseTracker Environment Variables" > "$SECRETS_FILE"
    echo "# Fill in your actual values" >> "$SECRETS_FILE"
    warn "Empty template created at $SECRETS_FILE"
  fi
fi

# Append Git config
echo "" >> "$SECRETS_FILE"
echo "# Git Configuration" >> "$SECRETS_FILE"
GIT_NAME=$(git config --global user.name 2>/dev/null || echo "")
GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")
[ -n "$GIT_NAME" ] && echo "GIT_USER_NAME=$GIT_NAME" >> "$SECRETS_FILE"
[ -n "$GIT_EMAIL" ] && echo "GIT_USER_EMAIL=$GIT_EMAIL" >> "$SECRETS_FILE"

# Encrypt unless --plain flag
if [ "$1" = "--plain" ]; then
  warn "Secrets saved as PLAIN TEXT at: $SECRETS_FILE"
  warn "Transfer this file securely and delete it after use!"
else
  if command -v gpg &>/dev/null; then
    info "Encrypting with GPG..."
    gpg --symmetric --cipher-algo AES256 -o "$ENCRYPTED_FILE" "$SECRETS_FILE"
    rm "$SECRETS_FILE"
    log "Encrypted secrets saved to: $ENCRYPTED_FILE"
    info "You'll need the passphrase you just entered on the new machine."
  else
    warn "GPG not available. Saving as plain text instead."
    warn "Secrets saved at: $SECRETS_FILE"
    warn "Transfer this file securely and delete it after use!"
  fi
fi

echo ""
info "Next: Copy the MySetup folder to your new PC and run setup.sh"
