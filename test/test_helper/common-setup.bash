#!/usr/bin/env bash

_common_setup() {
    PROJECT_ROOT="$(cd "$( dirname "$BATS_TEST_FILENAME" )/.." >/dev/null 2>&1 && pwd)"
    load "${PROJECT_ROOT}/test/test_helper/bats-support/load"
    load "${PROJECT_ROOT}/test/test_helper/bats-assert/load"

    export PATH="$PROJECT_ROOT:$PATH"

    # Isolated test environment
    export TEST_HOME="$(mktemp -d)"
    export HOME="$TEST_HOME"
    export BACKUP_DIR="$TEST_HOME/.claude-switch-backup"
    export SEQUENCE_FILE="$BACKUP_DIR/sequence.json"

    mkdir -p "$TEST_HOME/.claude"
    mkdir -p "$BACKUP_DIR"/{configs,credentials}
    chmod 700 "$BACKUP_DIR"
    chmod 700 "$BACKUP_DIR"/{configs,credentials}
}

_create_mock_claude_config() {
    local email="${1:-test@example.com}"
    local uuid="${2:-test-uuid-1234}"
    cat > "$TEST_HOME/.claude/.claude.json" <<EOF
{
  "oauthAccount": {
    "emailAddress": "$email",
    "accountUuid": "$uuid"
  }
}
EOF
}

_create_mock_credentials() {
    local creds="${1:-{\"token\":\"mock-token\"}}"
    printf '%s' "$creds" > "$TEST_HOME/.claude/.credentials.json"
    chmod 600 "$TEST_HOME/.claude/.credentials.json"
}

_seed_account() {
    local num="$1"
    local email="$2"
    local uuid="${3:-uuid-$num}"

    # Write config backup
    cat > "$BACKUP_DIR/configs/.claude-config-${num}-${email}.json" <<EOF
{
  "oauthAccount": {
    "emailAddress": "$email",
    "accountUuid": "$uuid"
  }
}
EOF
    chmod 600 "$BACKUP_DIR/configs/.claude-config-${num}-${email}.json"

    # Write credential backup
    printf '%s' "{\"token\":\"token-${num}\"}" > "$BACKUP_DIR/credentials/.claude-credentials-${num}-${email}.json"
    chmod 600 "$BACKUP_DIR/credentials/.claude-credentials-${num}-${email}.json"

    # Update sequence.json
    local now
    now=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    if [[ -f "$SEQUENCE_FILE" ]]; then
        local updated
        updated=$(jq --arg num "$num" --arg email "$email" --arg uuid "$uuid" --arg now "$now" '
            .accounts[$num] = { email: $email, uuid: $uuid, added: $now } |
            .sequence += [$num | tonumber] |
            .activeAccountNumber = ($num | tonumber) |
            .lastUpdated = $now
        ' "$SEQUENCE_FILE")
        echo "$updated" > "$SEQUENCE_FILE"
    else
        cat > "$SEQUENCE_FILE" <<EOF2
{
  "activeAccountNumber": $num,
  "lastUpdated": "$now",
  "sequence": [$num],
  "accounts": {
    "$num": { "email": "$email", "uuid": "$uuid", "added": "$now" }
  }
}
EOF2
    fi
    chmod 600 "$SEQUENCE_FILE"
}

_teardown_common() {
    rm -rf "$TEST_HOME"
}
