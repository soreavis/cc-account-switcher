# Changelog

All notable changes to this fork are documented here.

This project follows [Keep a Changelog](https://keepachangelog.com/) and [Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-03-15

First release of the security-hardened fork.

### Security

- Credentials passed via stdin instead of CLI arguments (no longer visible in `ps aux`)
- Re-enabled `wait_for_claude_close` to prevent config/credential corruption during switch
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

[1.0.0]: https://github.com/soreavis/cc-account-switcher/releases/tag/v1.0.0
