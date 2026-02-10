# install-ruby.sh — Install Ruby 3.2.2 via RubyInstaller

RUBY_VERSION="3.2.2"
RUBY_INSTALLER_URL="https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-${RUBY_VERSION}-1/rubyinstaller-devkit-${RUBY_VERSION}-1-x64.exe"
RUBY_INSTALLER_PATH="/tmp/rubyinstaller.exe"

if command -v ruby &>/dev/null; then
  CURRENT_RUBY=$(ruby -v | grep -oP '\d+\.\d+\.\d+')
  log "Ruby $CURRENT_RUBY already installed"
  if [[ "$CURRENT_RUBY" != "$RUBY_VERSION" ]]; then
    warn "Expected Ruby $RUBY_VERSION but found $CURRENT_RUBY"
    warn "You may need to install Ruby $RUBY_VERSION manually"
  fi
else
  info "Ruby not found. Downloading RubyInstaller $RUBY_VERSION..."
  curl -L -o "$RUBY_INSTALLER_PATH" "$RUBY_INSTALLER_URL"
  info "Launching RubyInstaller..."
  info "IMPORTANT: Check 'Add Ruby to PATH' and 'Run ridk install' during setup"
  start "" "$RUBY_INSTALLER_PATH"
  warn "MANUAL STEP: Complete the Ruby installer, then restart this script"
  warn "Press Enter after Ruby installation is complete..."
  read -r
fi
