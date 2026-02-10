# install-googledrive.sh — Install Google Drive for Desktop and sign in

GDRIVE_INSTALLER_URL="https://dl.google.com/drive-file-stream/GoogleDriveSetup.exe"
GDRIVE_INSTALLER_PATH="/tmp/GoogleDriveSetup.exe"
GDRIVE_ACCOUNT="elijahburrup323@gmail.com"

# Check if already installed
GDRIVE_EXE="/c/Program Files/Google/Drive File Stream/launch.bat"
GDRIVE_EXE_ALT="/c/Program Files/Google/Drive File Stream/GoogleDriveFS.exe"

if [ -f "$GDRIVE_EXE" ] || [ -f "$GDRIVE_EXE_ALT" ] || command -v "GoogleDriveFS" &>/dev/null 2>&1; then
  log "Google Drive for Desktop already installed"
else
  info "Downloading Google Drive for Desktop..."
  curl -L -o "$GDRIVE_INSTALLER_PATH" "$GDRIVE_INSTALLER_URL"

  if [ -f "$GDRIVE_INSTALLER_PATH" ]; then
    log "Download complete"
    info "Launching Google Drive installer (silent install)..."
    start "" "$GDRIVE_INSTALLER_PATH" --silent --desktop_shortcut
    info "Waiting for installation to complete..."

    # Wait for the install to finish (check every 5 seconds, up to 2 minutes)
    WAIT_COUNT=0
    while [ $WAIT_COUNT -lt 24 ]; do
      if [ -f "$GDRIVE_EXE" ] || [ -f "$GDRIVE_EXE_ALT" ]; then
        break
      fi
      sleep 5
      WAIT_COUNT=$((WAIT_COUNT + 1))
    done

    if [ -f "$GDRIVE_EXE" ] || [ -f "$GDRIVE_EXE_ALT" ]; then
      log "Google Drive for Desktop installed"
    else
      warn "Installation may still be in progress"
      warn "Press Enter once the installer finishes..."
      read -r
    fi

    rm -f "$GDRIVE_INSTALLER_PATH"
  else
    err "Download failed. Install manually from: https://www.google.com/drive/download/"
  fi
fi

# Sign in flow
echo ""
info "Google Drive needs to be signed in to: $GDRIVE_ACCOUNT"
info "This will open a browser window for Google sign-in."
echo ""
echo -n "Enter your Google password for $GDRIVE_ACCOUNT (to confirm you're ready): "
read -rs GDRIVE_PASSWORD
echo ""

if [ -z "$GDRIVE_PASSWORD" ]; then
  warn "No password entered — skipping Google Drive sign-in"
else
  log "Password confirmed. Opening Google Drive sign-in..."
  info "NOTE: Google uses browser-based OAuth — your password goes into the browser, not the terminal."
  info "The browser will open shortly. Sign in with: $GDRIVE_ACCOUNT"
  echo ""

  # Launch Google Drive which triggers the browser sign-in flow
  if [ -f "$GDRIVE_EXE" ]; then
    start "" "$GDRIVE_EXE"
  elif [ -f "$GDRIVE_EXE_ALT" ]; then
    start "" "$GDRIVE_EXE_ALT"
  else
    # Try common paths
    for path in \
      "/c/Program Files/Google/Drive File Stream/launch.bat" \
      "/c/Program Files/Google/Drive File Stream/GoogleDriveFS.exe" \
      "$LOCALAPPDATA/Google/Drive File Stream/GoogleDriveFS.exe" \
      "$APPDATA/../Local/Google/DriveFS/GoogleDriveFS.exe"; do
      if [ -f "$path" ]; then
        start "" "$path"
        break
      fi
    done
  fi

  info "Complete the sign-in in your browser with: $GDRIVE_ACCOUNT"
  info "Waiting for Google Drive to mount (G:\\ drive)..."
  echo ""

  # Wait for Google Drive to mount as G: drive
  WAIT_COUNT=0
  while [ $WAIT_COUNT -lt 60 ]; do
    if [ -d "/g/My Drive" ]; then
      break
    fi
    sleep 5
    WAIT_COUNT=$((WAIT_COUNT + 1))
    # Show a progress dot every 15 seconds
    if [ $((WAIT_COUNT % 3)) -eq 0 ]; then
      echo -n "."
    fi
  done
  echo ""

  if [ -d "/g/My Drive" ]; then
    log "Google Drive mounted at G:\\"

    # Check for ExpenseTracker Kanban folders
    if [ -d "/g/My Drive/ExpenseTracker" ]; then
      log "ExpenseTracker Kanban folder found!"
      [ -d "/g/My Drive/ExpenseTracker/1. Open Items" ] && log "  1. Open Items ✓"
      [ -d "/g/My Drive/ExpenseTracker/2. In Process" ] && log "  2. In Process ✓"
      [ -d "/g/My Drive/ExpenseTracker/3. Ready for QA" ] && log "  3. Ready for QA ✓"
    else
      warn "ExpenseTracker folder not found in Google Drive"
      info "It may take a moment to sync. Check G:\\My Drive\\ExpenseTracker\\ later."
    fi
  else
    warn "Google Drive not yet mounted at G:\\"
    warn "Sign-in may still be in progress. Check back after sign-in completes."
  fi
fi

# Clear password from memory
unset GDRIVE_PASSWORD
