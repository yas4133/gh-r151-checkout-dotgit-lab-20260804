#!/usr/bin/env bash
set -euo pipefail

canary_hash=$(printf '%s' "$R151_CANARY" | sha256sum | cut -d' ' -f1)
{
  printf 'R151_FORK_CODE_EXECUTED=1\n'
  printf 'R151_CANARY_SHA256=%s\n' "$canary_hash"
  printf 'R151_SOURCE_REPOSITORY=%s\n' "$GITHUB_REPOSITORY"
  printf 'R151_TRIGGER_ACTOR=%s\n' "$GITHUB_ACTOR"
} >> "$GITHUB_STEP_SUMMARY"
