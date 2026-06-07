#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

mkdir -p logs/maintenance
RUN_ID="$(date '+%Y%m%d_%H%M%S')"
LOG_FILE="logs/maintenance/${RUN_ID}.log"
LATEST_FAILURE="logs/maintenance/latest_failure.log"
TASK_JSON_FILE="$(mktemp)"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$LOG_FILE"
}

fail_without_commit() {
  log "FAIL: $*"
  cp "$LOG_FILE" "$LATEST_FAILURE"
  exit 1
}

log "PickMe maintenance started"
log "Project path: $ROOT_DIR"

if [[ "$(git rev-parse --show-toplevel)" != "$ROOT_DIR" ]]; then
  fail_without_commit "Git root mismatch"
fi

if [[ -n "$(git status --porcelain)" ]]; then
  log "SKIPPED: repository has uncommitted changes"
  log "No maintenance task was applied"
  exit 0
fi

python3 scripts/pickme_maintenance_task.py | tee "$TASK_JSON_FILE" | tee -a "$LOG_FILE" >/dev/null

TASK_STATUS="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["status"])' "$TASK_JSON_FILE")"
TASK_TITLE="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["title"])' "$TASK_JSON_FILE")"
COMMIT_MESSAGE="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["commit_message"])' "$TASK_JSON_FILE")"

log "Selected task: $TASK_TITLE"
log "Task status: $TASK_STATUS"

if [[ "$TASK_STATUS" == "skipped" ]]; then
  log "SKIPPED: no meaningful improvement available"
  exit 0
fi

if [[ -z "$(git status --porcelain)" ]]; then
  log "SKIPPED: task produced no file changes"
  exit 0
fi

log "Changed files:"
git status --short | tee -a "$LOG_FILE"

log "Running flutter pub get"
flutter pub get >>"$LOG_FILE" 2>&1 || fail_without_commit "flutter pub get failed"

log "Running flutter analyze"
flutter analyze >>"$LOG_FILE" 2>&1 || fail_without_commit "flutter analyze failed"

log "Running flutter test"
flutter test >>"$LOG_FILE" 2>&1 || fail_without_commit "flutter test failed"

log "Running flutter build apk --debug"
flutter build apk --debug >>"$LOG_FILE" 2>&1 || fail_without_commit "flutter build apk --debug failed"

log "Verification passed"

git add -A
git commit -m "$COMMIT_MESSAGE" >>"$LOG_FILE" 2>&1 || fail_without_commit "git commit failed"
COMMIT_HASH="$(git rev-parse --short HEAD)"
log "Commit created: $COMMIT_HASH"

git push origin main >>"$LOG_FILE" 2>&1 || fail_without_commit "git push failed"
log "Push completed"
log "PickMe maintenance finished successfully"
