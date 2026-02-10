#!/usr/bin/env bash
# =============================================================================
# MySetup - Fresh PC Bootstrap for BudgetHQ Development Environment
# =============================================================================
# Run from Git Bash (MINGW64) on Windows:
#   bash setup.sh
#
# Prerequisites: Git Bash installed (https://git-scm.com/download/win)
# =============================================================================

set -e

PROJECTS_DIR="/c/Projects"
SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)/scripts"
SECRETS_DIR="$(cd "$(dirname "$0")" && pwd)/secrets"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()   { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
err()   { echo -e "${RED}[✗]${NC} $1"; }
info()  { echo -e "${CYAN}[i]${NC} $1"; }
step()  { echo -e "\n${CYAN}━━━ $1 ━━━${NC}\n"; }

# =============================================================================
# Step 1: System-level software installs
# =============================================================================
step "Step 1: Installing System Software"

source "$SCRIPTS_DIR/install-ruby.sh"
source "$SCRIPTS_DIR/install-node.sh"
source "$SCRIPTS_DIR/install-postgresql.sh"
source "$SCRIPTS_DIR/install-extras.sh"

# =============================================================================
# Step 2: Clone repositories
# =============================================================================
step "Step 2: Cloning Repositories"

mkdir -p "$PROJECTS_DIR"

if [ -d "$PROJECTS_DIR/ExpenseTracker/.git" ]; then
  log "ExpenseTracker already cloned"
else
  info "Cloning ExpenseTracker..."
  git clone https://github.com/elijahburrup323-droid/ExpenseTracker.git "$PROJECTS_DIR/ExpenseTracker"
  log "ExpenseTracker cloned"
fi

if [ -d "$PROJECTS_DIR/IssueAutomation/.git" ]; then
  log "IssueAutomation already cloned"
else
  mkdir -p "$PROJECTS_DIR/IssueAutomation"
  log "IssueAutomation directory created (empty project placeholder)"
fi

# =============================================================================
# Step 3: Restore secrets / environment variables
# =============================================================================
step "Step 3: Setting Up Environment Variables"

if [ -f "$SECRETS_DIR/secrets.env.gpg" ]; then
  info "Encrypted secrets file found. Decrypting..."
  source "$SCRIPTS_DIR/import-secrets.sh"
elif [ -f "$SECRETS_DIR/secrets.env" ]; then
  info "Unencrypted secrets file found. Copying to projects..."
  cp "$SECRETS_DIR/secrets.env" "$PROJECTS_DIR/ExpenseTracker/.env"
  log "Secrets restored to ExpenseTracker/.env"
else
  warn "No secrets file found. You'll need to configure .env manually."
  warn "Copy .env.example to .env and fill in your API keys:"
  warn "  cp $PROJECTS_DIR/ExpenseTracker/.env.example $PROJECTS_DIR/ExpenseTracker/.env"
  info "Or export from your current machine first using: bash secrets/export-secrets.sh"
fi

# =============================================================================
# Step 4: Install project dependencies
# =============================================================================
step "Step 4: Installing Project Dependencies"

cd "$PROJECTS_DIR/ExpenseTracker"

info "Installing Ruby gems..."
gem install bundler --no-document
bundle install
log "Ruby gems installed"

info "Installing Node packages..."
npm install
log "Node packages installed"

info "Installing Playwright browsers..."
npx playwright install
log "Playwright browsers installed"

# =============================================================================
# Step 5: Database setup
# =============================================================================
step "Step 5: Setting Up Database"

info "Make sure PostgreSQL is running, then press Enter to continue..."
read -r

cd "$PROJECTS_DIR/ExpenseTracker"

info "Creating databases..."
bundle exec rails db:create 2>/dev/null || warn "Databases may already exist"

info "Running migrations..."
bundle exec rails db:migrate
log "Database migrated"

info "Seeding development data..."
bundle exec rails db:seed 2>/dev/null || warn "Seed data may already exist"
log "Database setup complete"

# =============================================================================
# Step 6: Google Drive setup
# =============================================================================
step "Step 6: Google Drive Setup"

info "BudgetHQ uses Google Drive for Kanban workflow."
info "Expected path: G:\\My Drive\\ExpenseTracker\\"
echo ""
warn "MANUAL STEP: Install Google Drive for Desktop"
info "  1. Download from: https://www.google.com/drive/download/"
info "  2. Sign in with your Google account"
info "  3. Google Drive will mount as G:\\ drive"
info "  4. Verify the folder structure exists:"
info "     G:\\My Drive\\ExpenseTracker\\1. Open Items"
info "     G:\\My Drive\\ExpenseTracker\\2. In Process"
info "     G:\\My Drive\\ExpenseTracker\\3. Ready for QA"
echo ""
info "Press Enter after setting up Google Drive (or to skip for now)..."
read -r

# Verify Google Drive
if [ -d "/g/My Drive/ExpenseTracker" ]; then
  log "Google Drive ExpenseTracker folder found!"
else
  warn "Google Drive folder not found at expected path."
  warn "You can set this up later."
fi

# =============================================================================
# Step 7: Claude Code CLI setup
# =============================================================================
step "Step 7: Claude Code CLI"

if command -v claude &>/dev/null; then
  log "Claude Code CLI already installed"
else
  info "Installing Claude Code CLI..."
  npm install -g @anthropic-ai/claude-code 2>/dev/null || warn "Claude Code install failed - install manually"
fi

# =============================================================================
# Summary
# =============================================================================
step "Setup Complete!"

echo ""
log "Projects cloned to $PROJECTS_DIR"
log "Dependencies installed"
echo ""
info "Next steps:"
info "  1. Verify your .env file: $PROJECTS_DIR/ExpenseTracker/.env"
info "  2. Start the dev server: cd $PROJECTS_DIR/ExpenseTracker && bin/dev"
info "  3. Visit: http://localhost:3000"
info "  4. Test login: test@example.com / password123"
echo ""

# Check what still needs manual attention
echo -e "${YELLOW}Manual items to verify:${NC}"
[ ! -f "$PROJECTS_DIR/ExpenseTracker/.env" ] && echo "  - Create .env file from .env.example"
! command -v ruby &>/dev/null && echo "  - Ruby not on PATH (restart terminal)"
! command -v node &>/dev/null && echo "  - Node not on PATH (restart terminal)"
! command -v psql &>/dev/null && echo "  - PostgreSQL not on PATH (restart terminal)"
[ ! -d "/g/My Drive/ExpenseTracker" ] && echo "  - Google Drive not set up"
echo ""
log "Done! Happy coding."
