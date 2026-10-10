# Changelog

All notable changes to this fork are documented here.

This project follows [Keep a Changelog](https://keepachangelog.com/) and [Semantic Versioning](https://semver.org/).

## [1.0.2] - 2026-10-10

### Fixed

- `--switch` and `--switch-to` refused a missing backup but restored one saved as `-` by 1.0.0 on macOS, writing `-` over the live credentials again. They now refuse it too and print the repair steps.
- `--switch` and `--switch-to` never waited for Claude Code to close: `is_claude_running` always returned false, because awk runs the `END` block after `exit` and `END` exited 1. Inherited from upstream.
- Live credentials of `-`, which a 1.0.0 switch left until the next login, were saved as a backup: by `--add-account` as the new account's, and by `--switch` and `--switch-to` over the current account's. `--add-account` now refuses them, and a switch keeps the existing backup.

### Added

- README: how to repair accounts saved by 1.0.0 on macOS, and that re-added accounts get new numbers
- Bats test for switching to a backup saved as `-`
- Bats test that `--switch` waits for a running Claude Code; the tests stub `ps`, so a Claude Code running on the host doesn't block them
- Bats tests for live credentials of `-` in `--add-account` and `--switch`

## [1.0.1] - 2026-10-09

### Fixed

- macOS: Keychain writes stored a literal `-` instead of the credentials. `security add-generic-password` does not treat `-w -` as stdin; it takes `-` literally as the password. Credentials are passed as the `-w` argument again, as upstream does.

### Security

- Reverts the 1.0.0 stdin change: on macOS, credentials are visible in the process list while `security` runs, as in upstream.

### Added

- Bats test that runs the macOS Keychain write path against a stub `security`

## [1.0.0] - 2026-03-15

First release of the security-hardened fork.

### Security

- ~~Credentials passed via stdin instead of CLI arguments (no longer visible in `ps aux`)~~ Correction: this broke macOS Keychain writes and was reverted in 1.0.1
- Re-enabled `wait_for_claude_close` to prevent config/credential corruption during switch. Correction: it never detected a running Claude Code until 1.0.2
- Temp file permissions (`chmod 600`) applied immediately after creation, before writing content
- Backup integrity validation before restore (JSON structure + email mismatch check)

### Added

- `--version` flag to display version number
- `--status` command showing version, platform, current account, and managed account count
- `CCSWITCH_PLATFORM` environment variable for platform override (used in testing)
- Bats test suite with 12 tests covering all commands and edge cases
- GitHub Actions CI running ShellCheck and tests on every push/PR
- CHANGELOG.md
- CONTRIBUTING.md

### Fixed

- ShellCheck SC2043: single-iteration loop replaced with direct command check
- ShellCheck SC2155: separated declaration and assignment in `init_sequence_file`
- ShellCheck SC2181: replaced `$?` check with direct exit code test
- Replaced unquoted command substitution with `mapfile -t` for safe array population

[1.0.2]: https://github.com/soreavis/cc-account-switcher/releases/tag/v1.0.2
[1.0.1]: https://github.com/soreavis/cc-account-switcher/releases/tag/v1.0.1
[1.0.0]: https://github.com/soreavis/cc-account-switcher/releases/tag/v1.0.0
