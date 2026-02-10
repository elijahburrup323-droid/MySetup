# MySetup

Automated setup for a fresh Windows PC to get the BudgetHQ development environment running.

## What It Installs

| Software | Version | Purpose |
|----------|---------|---------|
| Ruby | 3.2.2 | Rails runtime |
| Node.js | LTS | Asset pipeline, Playwright |
| PostgreSQL | 16 | Database |
| VS Code | Latest | Editor |
| GitHub CLI | Latest | Git operations |
| Claude Code | Latest | AI-assisted development |
| Playwright | Latest | E2E browser testing |
| Google Drive | Desktop | Kanban workflow (G: drive) |

## Quick Start

### On your current machine (export secrets first):
```bash
cd C:/Projects/MySetup
bash secrets/export-secrets.sh
```

### On the new machine:
1. Install [Git for Windows](https://git-scm.com/download/win)
2. Copy the MySetup folder (USB drive, cloud, etc.)
3. Open Git Bash and run:
```bash
cd /c/Projects/MySetup
bash setup.sh
```

## Project Structure

```
MySetup/
├── setup.sh                  # Main bootstrap script
├── scripts/
│   ├── install-ruby.sh       # Ruby 3.2.2 via RubyInstaller
│   ├── install-node.sh       # Node.js LTS
│   ├── install-postgresql.sh # PostgreSQL 16
│   ├── install-extras.sh     # VS Code, GitHub CLI, Git config
│   └── import-secrets.sh     # Decrypt & restore .env files
├── secrets/
│   └── export-secrets.sh     # Export secrets from current machine
├── .gitignore
└── README.md
```

## Environment Variables

The setup restores these to `ExpenseTracker/.env`:

- **Database**: `DATABASE_HOST`, `DATABASE_USERNAME`, `DATABASE_PASSWORD`, `DATABASE_NAME`
- **Rails**: `SECRET_KEY_BASE`, `RAILS_ENV`
- **Google OAuth**: `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`
- **Apple Sign-In**: `APPLE_CLIENT_ID`, `APPLE_TEAM_ID`, `APPLE_KEY_ID`, `APPLE_PRIVATE_KEY`
- **Microsoft OAuth**: `MICROSOFT_CLIENT_ID`, `MICROSOFT_CLIENT_SECRET`
- **Twilio SMS**: `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_PHONE_NUMBER`
- **App**: `APP_HOST`

## Manual Steps

Some things need manual interaction during setup:
1. **RubyInstaller** — check "Add to PATH" and "Run ridk install"
2. **PostgreSQL** — set the postgres user password
3. **Google Drive** — sign into your Google account
4. **GitHub** — run `gh auth login` to authenticate
