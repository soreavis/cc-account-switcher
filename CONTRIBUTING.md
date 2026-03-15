# Contributing

Contributions are welcome. This is a security-hardened fork of [ming86/cc-account-switcher](https://github.com/ming86/cc-account-switcher).

## Getting started

```bash
git clone --recurse-submodules git@github.com:soreavis/cc-account-switcher.git
cd cc-account-switcher
```

If you already cloned without `--recurse-submodules`:

```bash
git submodule update --init --recursive
```

## Running tests

```bash
./test/bats/bin/bats test/*.bats
```

## Linting

ShellCheck must pass with zero warnings:

```bash
shellcheck ccswitch.sh
```

## Submitting changes

1. Fork this repo
2. Create a branch (`fix/description` or `feat/description`)
3. Make your changes
4. Ensure `shellcheck ccswitch.sh` passes clean
5. Ensure all tests pass
6. Open a pull request

## Upstream sync

This fork tracks `ming86/cc-account-switcher` as `upstream`. Security fixes are submitted back to upstream when applicable.

```bash
git fetch upstream
git merge upstream/main
```
