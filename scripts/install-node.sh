# install-node.sh — Install Node.js LTS

NODE_INSTALLER_URL="https://nodejs.org/dist/v20.11.1/node-v20.11.1-x64.msi"
NODE_INSTALLER_PATH="/tmp/node-installer.msi"

if command -v node &>/dev/null; then
  CURRENT_NODE=$(node -v)
  log "Node.js $CURRENT_NODE already installed"
else
  info "Node.js not found. Downloading Node.js LTS..."
  curl -L -o "$NODE_INSTALLER_PATH" "$NODE_INSTALLER_URL"
  info "Launching Node.js installer..."
  start "" "$NODE_INSTALLER_PATH"
  warn "MANUAL STEP: Complete the Node.js installer, then restart this script"
  warn "Press Enter after Node.js installation is complete..."
  read -r
fi

# Verify npm
if command -v npm &>/dev/null; then
  log "npm $(npm -v) available"
else
  warn "npm not found — restart your terminal after Node.js install"
fi
