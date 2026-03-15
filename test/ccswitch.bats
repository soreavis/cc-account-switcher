#!/usr/bin/env bats

setup() {
    load 'test_helper/common-setup'
    _common_setup
    export CCSWITCH_PLATFORM="linux"
}

teardown() {
    _teardown_common
}

# --- Basic commands ---

@test "--help shows usage information" {
    run ccswitch.sh --help
    assert_success
    assert_output --partial "Multi-Account Switcher for Claude Code"
    assert_output --partial "--add-account"
    assert_output --partial "--switch"
    assert_output --partial "--status"
}

@test "--version shows version string" {
    run ccswitch.sh --version
    assert_success
    assert_output --partial "ccswitch v"
}

@test "--status shows version and platform" {
    _create_mock_claude_config "user@test.com"
    _seed_account "1" "user@test.com"
    run ccswitch.sh --status
    assert_success
    assert_output --partial "ccswitch v"
    assert_output --partial "Platform: linux"
    assert_output --partial "Current account: user@test.com"
    assert_output --partial "Managed accounts: 1"
}

@test "invalid command shows error and usage" {
    run ccswitch.sh --bogus
    assert_failure
    assert_output --partial "Error: Unknown command"
    assert_output --partial "Usage:"
}

# --- Add account ---

@test "--add-account adds current account" {
    _create_mock_claude_config "new@test.com" "uuid-new"
    _create_mock_credentials '{"token":"new-token"}'
    run ccswitch.sh --add-account
    assert_success
    assert_output --partial "Added Account 1: new@test.com"

    # Verify sequence.json was created
    [ -f "$SEQUENCE_FILE" ]
    local email
    email=$(jq -r '.accounts["1"].email' "$SEQUENCE_FILE")
    [ "$email" = "new@test.com" ]
}

@test "--add-account rejects when no active account" {
    run ccswitch.sh --add-account
    assert_failure
    assert_output --partial "No active Claude account found"
}

@test "--add-account rejects duplicate account" {
    _create_mock_claude_config "dup@test.com" "uuid-dup"
    _create_mock_credentials '{"token":"dup-token"}'
    _seed_account "1" "dup@test.com" "uuid-dup"
    run ccswitch.sh --add-account
    assert_success
    assert_output --partial "already managed"
}

# --- List ---

@test "--list shows managed accounts" {
    _create_mock_claude_config "a@test.com"
    _seed_account "1" "a@test.com"
    _seed_account "2" "b@test.com"
    run ccswitch.sh --list
    assert_success
    assert_output --partial "a@test.com"
    assert_output --partial "b@test.com"
}

@test "--list shows active marker on current account" {
    _create_mock_claude_config "a@test.com"
    _seed_account "1" "a@test.com"
    _seed_account "2" "b@test.com"
    run ccswitch.sh --list
    assert_success
    assert_output --partial "a@test.com (active)"
}

# --- Switch ---

@test "--switch rotates to next account" {
    _create_mock_claude_config "a@test.com" "uuid-a"
    _create_mock_credentials '{"token":"token-a"}'
    _seed_account "1" "a@test.com" "uuid-a"
    _seed_account "2" "b@test.com" "uuid-b"

    # _seed_account sets activeAccountNumber to last seeded (2), reset to 1
    local updated
    updated=$(jq '.activeAccountNumber = 1' "$SEQUENCE_FILE")
    echo "$updated" > "$SEQUENCE_FILE"

    run ccswitch.sh --switch
    assert_success
    assert_output --partial "Switched to Account-2 (b@test.com)"
}

# --- Remove ---

@test "--remove-account removes with confirmation" {
    _create_mock_claude_config "a@test.com"
    _seed_account "1" "a@test.com"
    _seed_account "2" "remove@test.com"

    run bash -c "echo y | ccswitch.sh --remove-account 2"
    assert_success
    assert_output --partial "remove@test.com"
    assert_output --partial "has been removed"
}

@test "--remove-account rejects nonexistent account" {
    _create_mock_claude_config "a@test.com"
    _seed_account "1" "a@test.com"

    run ccswitch.sh --remove-account 99
    assert_failure
    assert_output --partial "does not exist"
}
