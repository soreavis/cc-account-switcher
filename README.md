# Multi-Account Switcher for Claude Code

[![CI](https://github.com/soreavis/cc-account-switcher/actions/workflows/ci.yml/badge.svg)](https://github.com/soreavis/cc-account-switcher/actions/workflows/ci.yml)
![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Bash](https://img.shields.io/badge/bash-4.4%2B-green?logo=gnubash&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-blue)

> **Fork of [ming86/cc-account-switcher](https://github.com/ming86/cc-account-switcher)** — security-hardened by Julian Soreavis with Claude Code.

> [!WARNING]
> This tool accesses and stores authentication credentials. Review the source code before use. The authors are not responsible for credential loss or unauthorized access. Use at your own risk.

A simple tool to manage and switch between multiple Claude Code accounts on macOS, Linux, and WSL.

## Features

- **Multi-account management**: Add, remove, and list Claude Code accounts
- **Quick switching**: Switch between accounts with simple commands
- **Cross-platform**: Works on macOS, Linux, and WSL
- **Secure storage**: Uses system keychain (macOS) or protected files (Linux/WSL)
- **Settings preservation**: Only switches authentication - your themes, settings, and preferences remain unchanged

## Security Enhancements (Fork)

This fork includes the following security hardening over the upstream version:

1. **Credentials no longer exposed in process list** — Keychain writes use stdin (`-w -`) instead of passing credentials as CLI arguments visible via `ps aux`
2. **Switch-while-running protection re-enabled** — `wait_for_claude_close` is active in both `--switch` and `--switch-to`, preventing config/credential corruption if Claude Code is running
3. **Temp file race condition eliminated** — `chmod 600` applied immediately after `mktemp`, before any content is written
4. **Safe array population** — Replaced unquoted command substitution with `mapfile -t` to prevent word splitting
5. **Backup integrity validation** — Restored configs are validated for valid JSON and email match before being applied, preventing tampered backup injection
6. **Restrictive file permissions from creation** — Temp files are locked down before sensitive data touches disk

## Installation

Download the script directly:

```bash
curl -O https://raw.githubusercontent.com/soreavis/cc-account-switcher/main/ccswitch.sh
chmod +x ccswitch.sh
```

Or install to your PATH for global access:

```bash
curl -fsSL https://raw.githubusercontent.com/soreavis/cc-account-switcher/main/ccswitch.sh -o /usr/local/bin/ccswitch && chmod +x /usr/local/bin/ccswitch
```

## Usage

### Basic Commands

```bash
# Add current account to managed accounts
./ccswitch.sh --add-account

# List all managed accounts
./ccswitch.sh --list

# Switch to next account in sequence
./ccswitch.sh --switch

# Switch to specific account by number or email
./ccswitch.sh --switch-to 2
./ccswitch.sh --switch-to user2@example.com

# Remove an account
./ccswitch.sh --remove-account user2@example.com

# Show current account and version info
./ccswitch.sh --status

# Show version
./ccswitch.sh --version

# Show help
./ccswitch.sh --help
```

### First Time Setup

1. **Log into Claude Code** with your first account (make sure you're actively logged in)
2. Run `./ccswitch.sh --add-account` to add it to managed accounts
3. **Log out** and log into Claude Code with your second account
4. Run `./ccswitch.sh --add-account` again
5. Now you can switch between accounts with `./ccswitch.sh --switch`
6. **Important**: After each switch, restart Claude Code to use the new authentication

> **What gets switched:** Only your authentication credentials change. Your themes, settings, preferences, and chat history remain exactly the same.

## Requirements

- Bash 4.4+
- `jq` (JSON processor)

### Installing Dependencies

**macOS:**

```bash
brew install jq
```

**Ubuntu/Debian:**

```bash
sudo apt install jq
```

## How It Works

The switcher stores account authentication data separately:

- **macOS**: Credentials in Keychain, OAuth info in `~/.claude-switch-backup/`
- **Linux/WSL**: Both credentials and OAuth info in `~/.claude-switch-backup/` with restricted permissions

When switching accounts, it:

1. Backs up the current account's authentication data
2. Restores the target account's authentication data
3. Updates Claude Code's authentication files

## Troubleshooting

### If a switch fails

- Check that you have accounts added: `./ccswitch.sh --list`
- Verify Claude Code is closed before switching
- Try switching back to your original account

### If you can't add an account

- Make sure you're logged into Claude Code first
- Check that you have `jq` installed
- Verify you have write permissions to your home directory

### If Claude Code doesn't recognize the new account

- Make sure you restarted Claude Code after switching
- Check the current account: `./ccswitch.sh --list` (look for "(active)")

## Cleanup/Uninstall

To stop using this tool and remove all data:

1. Note your current active account: `./ccswitch.sh --list`
2. Remove the backup directory: `rm -rf ~/.claude-switch-backup`
3. Delete the script: `rm ccswitch.sh`

Your current Claude Code login will remain active.

## Security Notes

- Credentials stored in macOS Keychain or files with 600 permissions
- Authentication files are stored with restricted permissions (600)
- The tool requires Claude Code to be closed during account switches
- Backup integrity is validated before restore to prevent tampered credential injection

## Credits

- **Original author**: [Ming](https://github.com/ming86)
- **Fork maintained by**: [Julian Soreavis](https://github.com/soreavis)
- **Security audit & fixes**: Julian Soreavis with [Claude Code](https://claude.ai/code)

## License

MIT License - see LICENSE file for details
