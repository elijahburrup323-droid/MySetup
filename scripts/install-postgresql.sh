# install-postgresql.sh — Install PostgreSQL

PG_VERSION="16"
PG_INSTALLER_URL="https://sbp.enterprisedb.com/getfile.jsp?fileid=1259105&_ga=2.0.0"

if command -v psql &>/dev/null; then
  CURRENT_PG=$(psql --version | grep -oP '\d+\.\d+')
  log "PostgreSQL $CURRENT_PG already installed"
else
  info "PostgreSQL not found."
  info "Download PostgreSQL $PG_VERSION from: https://www.enterprisedb.com/downloads/postgres-postgresql-downloads"
  info "Or install via winget:"
  echo ""
  echo "    winget install PostgreSQL.PostgreSQL.16"
  echo ""
  warn "MANUAL STEP: Install PostgreSQL, remember your password"
  warn "During install: keep default port 5432, set password for 'postgres' user"
  warn "Press Enter after PostgreSQL installation is complete..."
  read -r
fi

# Check if PostgreSQL service is running
if pg_isready &>/dev/null 2>&1; then
  log "PostgreSQL is running"
else
  warn "PostgreSQL service does not appear to be running"
  info "Start it from Windows Services or run: pg_ctl start"
fi
