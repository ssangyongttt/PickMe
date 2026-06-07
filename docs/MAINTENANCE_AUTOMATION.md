# Maintenance Automation

PickMe uses a local macOS launchd schedule for small, real maintenance improvements. The automation is intended to keep the public repository healthy without creating fake activity.

## Purpose

- Apply at most one small improvement per run
- Keep changes focused and reviewable
- Run Flutter verification before committing
- Push only when verification succeeds
- Skip when no meaningful improvement is available

The automation does not add ads, analytics, payments, Firebase, external APIs, server features, or personal data collection.

## Schedule

- Tuesday 21:30
- Friday 21:30
- Local Mac time
- launchd label: `com.jsoh.pickme.maintenance`

## What It Can Change

The task runner chooses one eligible maintenance task per run, such as:

- Add or improve contribution documentation
- Add or improve changelog content
- Clarify roadmap or project overview wording
- Improve README documentation links
- Improve issue template wording

If all predefined improvements already exist, the run is recorded as `SKIPPED` and no commit is created.

## Verification Commands

Every successful maintenance change must pass:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

If any command fails, the script does not commit or push.

## Manual Run

```bash
cd /Users/jsoh/Desktop/dev/PickMe
scripts/run_maintenance_once.sh
```

## launchd Registration

The plist template is stored in:

```bash
launchd/com.jsoh.pickme.maintenance.plist
```

Install it with:

```bash
cd /Users/jsoh/Desktop/dev/PickMe
scripts/install_launchd.sh
```

The install script copies the plist to:

```bash
~/Library/LaunchAgents/com.jsoh.pickme.maintenance.plist
```

## Stop and Remove

```bash
cd /Users/jsoh/Desktop/dev/PickMe
scripts/uninstall_launchd.sh
```

## Logs

Per-run logs:

```bash
logs/maintenance/YYYYMMDD_HHMMSS.log
```

Latest failure log:

```bash
logs/maintenance/latest_failure.log
```

launchd stdout and stderr:

```bash
logs/maintenance/launchd_stdout.log
logs/maintenance/launchd_stderr.log
```

## Failure Recovery

1. Open `logs/maintenance/latest_failure.log`.
2. Review the failed command and changed files.
3. Fix the issue locally.
4. Re-run the verification commands manually.
5. Commit and push only after verification passes.

The script intentionally leaves failed changes in the working tree so they can be inspected instead of hidden or reverted automatically.
