#!/usr/bin/env bash
# Headless vault sync. Run by encephalon-sync.timer (weekly) or by hand.
set -u
VAULT="$(cd "$(dirname "$0")/.." && pwd)"
LOCK="$VAULT/scripts/.sync.lock"
LOG="$VAULT/scripts/sync.log"

if [ -e "$LOCK" ]; then
  echo "$(date -Is) skipped: lock present" >> "$LOG"
  exit 0
fi
trap 'rm -f "$LOCK"' EXIT
: > "$LOCK"

start=$(date +%s)
cd "$VAULT"
claude -p "/sync headless" \
  --allowedTools "Read,Write,Edit,Glob,Grep,Bash(git:*),Bash(gh api:*)" \
  >> "$LOG" 2>&1
code=$?
echo "$(date -Is) exit=$code duration=$(( $(date +%s) - start ))s" >> "$LOG"
exit "$code"
