# install-extras.sh — Install additional tools

# VS Code
if command -v code &>/dev/null; then
  log "VS Code already installed"
else
  info "VS Code not found. Install from: https://code.visualstudio.com/"
  info "Or run: winget install Microsoft.VisualStudioCode"
fi

# GitHub CLI
if command -v gh &>/dev/null; then
  log "GitHub CLI already installed ($(gh --version | head -1))"
else
  info "Installing GitHub CLI..."
  info "Download from: https://cli.github.com/"
  info "Or run: winget install GitHub.cli"
fi

# Git configuration
info "Configuring Git..."
CURRENT_NAME=$(git config --global user.name 2>/dev/null || echo "")
CURRENT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

if [ -z "$CURRENT_NAME" ]; then
  echo -n "Enter your Git name: "
  read -r GIT_NAME
  git config --global user.name "$GIT_NAME"
  log "Git name set to: $GIT_NAME"
else
  log "Git name: $CURRENT_NAME"
fi

if [ -z "$CURRENT_EMAIL" ]; then
  echo -n "Enter your Git email: "
  read -r GIT_EMAIL
  git config --global user.email "$GIT_EMAIL"
  log "Git email set to: $GIT_EMAIL"
else
  log "Git email: $CURRENT_EMAIL"
fi

# GitHub authentication
if gh auth status &>/dev/null 2>&1; then
  log "GitHub CLI authenticated"
else
  warn "GitHub CLI not authenticated"
  info "Run: gh auth login"
fi
