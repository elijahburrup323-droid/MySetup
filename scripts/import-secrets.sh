# import-secrets.sh — Decrypt and restore secrets to project .env files
# Called by setup.sh when secrets.env.gpg is found

SECRETS_DIR="$(cd "$(dirname "$0")/../secrets" && pwd)"
ENCRYPTED_FILE="$SECRETS_DIR/secrets.env.gpg"
DECRYPTED_FILE="$SECRETS_DIR/secrets.env"

if [ -f "$ENCRYPTED_FILE" ]; then
  info "Decrypting secrets..."
  gpg --decrypt -o "$DECRYPTED_FILE" "$ENCRYPTED_FILE"

  if [ -f "$DECRYPTED_FILE" ]; then
    # Copy to ExpenseTracker (strip Git config lines)
    grep -v "^GIT_USER_" "$DECRYPTED_FILE" | grep -v "^# Git Configuration" > "$PROJECTS_DIR/ExpenseTracker/.env"
    log "Secrets restored to ExpenseTracker/.env"

    # Restore Git config
    GIT_NAME=$(grep "^GIT_USER_NAME=" "$DECRYPTED_FILE" | cut -d'=' -f2-)
    GIT_EMAIL=$(grep "^GIT_USER_EMAIL=" "$DECRYPTED_FILE" | cut -d'=' -f2-)
    [ -n "$GIT_NAME" ] && git config --global user.name "$GIT_NAME" && log "Git name set: $GIT_NAME"
    [ -n "$GIT_EMAIL" ] && git config --global user.email "$GIT_EMAIL" && log "Git email set: $GIT_EMAIL"

    # Clean up decrypted file
    rm "$DECRYPTED_FILE"
    log "Decrypted file cleaned up"
  else
    err "Decryption failed"
  fi
else
  warn "No encrypted secrets file found at $ENCRYPTED_FILE"
fi
