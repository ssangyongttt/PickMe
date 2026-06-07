#!/usr/bin/env python3
"""Apply one small, real maintenance improvement for PickMe.

The task runner is intentionally conservative. It applies at most one change per
run and skips when the repository already contains the planned improvement.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


@dataclass(frozen=True)
class TaskResult:
    status: str
    title: str
    commit_message: str
    changed_files: list[str]
    reason: str = ""


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8") if path.exists() else ""


def write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def ensure_contributing() -> TaskResult | None:
    path = ROOT / "CONTRIBUTING.md"
    if path.exists():
        return None

    write_text(
        path,
        """# Contributing

Thanks for your interest in PickMe.

PickMe is intentionally small, privacy-friendly, and easy to review. Please keep changes focused and avoid adding services, SDKs, or features that collect personal data.

## Good First Contributions

- Improve README wording or screenshots
- Clarify roadmap items
- Add small widget tests
- Improve accessibility labels
- Polish simple UI copy

## Development

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

## Pull Request Guidelines

- Keep the change small and easy to review
- Explain the user value
- Include tests when behavior changes
- Do not add ads, analytics, payments, Firebase, external APIs, or server features

## Privacy Baseline

PickMe does not require an account, does not collect personal information, does not use analytics, and does not show ads.
""",
    )
    return TaskResult(
        status="changed",
        title="Add contribution guide",
        commit_message="chore: add contribution guide",
        changed_files=["CONTRIBUTING.md"],
    )


def ensure_changelog() -> TaskResult | None:
    path = ROOT / "CHANGELOG.md"
    if path.exists():
        return None

    write_text(
        path,
        """# Changelog

## v1.0.0

- Added the initial PickMe Flutter app
- Added random decision picking with multiple options
- Added recent decision history
- Added Material Design UI with dark mode support
- Added README, MIT License, privacy notes, roadmap, GitHub Actions, issue templates, screenshots, and release assets
""",
    )
    return TaskResult(
        status="changed",
        title="Add changelog",
        commit_message="docs: add changelog",
        changed_files=["CHANGELOG.md"],
    )


def improve_roadmap() -> TaskResult | None:
    path = ROOT / "docs" / "ROADMAP.md"
    text = read_text(path)
    marker = "## Maintenance Principles"
    if marker in text:
        return None

    updated = text.rstrip() + """

## Maintenance Principles

- Prefer small improvements over large feature jumps
- Keep the app local-first and privacy-friendly
- Add tests when behavior changes
- Avoid external services unless there is a clear user benefit
"""
    write_text(path, updated)
    return TaskResult(
        status="changed",
        title="Clarify roadmap maintenance principles",
        commit_message="docs: improve project roadmap",
        changed_files=["docs/ROADMAP.md"],
    )


def improve_readme() -> TaskResult | None:
    path = ROOT / "README.md"
    text = read_text(path)
    marker = "## Documentation"
    if marker in text:
        return None

    insert_after = "See the full roadmap in [docs/ROADMAP.md](docs/ROADMAP.md).\n"
    documentation = """
## Documentation

- [Project Overview](docs/PROJECT_OVERVIEW.md)
- [Privacy](docs/PRIVACY.md)
- [Roadmap](docs/ROADMAP.md)
- [Maintenance Automation](docs/MAINTENANCE_AUTOMATION.md)
"""
    if insert_after not in text:
        return None

    write_text(path, text.replace(insert_after, insert_after + documentation))
    return TaskResult(
        status="changed",
        title="Add README documentation links",
        commit_message="docs: improve README documentation links",
        changed_files=["README.md"],
    )


def improve_issue_template() -> TaskResult | None:
    path = ROOT / ".github" / "ISSUE_TEMPLATE" / "bug_report.md"
    text = read_text(path)
    marker = "## Privacy or Data Impact"
    if marker in text or not text:
        return None

    updated = text.rstrip() + """

## Privacy or Data Impact

Does this issue affect local storage, privacy expectations, or user data handling?
"""
    write_text(path, updated)
    return TaskResult(
        status="changed",
        title="Add privacy prompt to bug template",
        commit_message="docs: improve bug report template",
        changed_files=[".github/ISSUE_TEMPLATE/bug_report.md"],
    )


TASKS = (
    ensure_contributing,
    ensure_changelog,
    improve_roadmap,
    improve_readme,
    improve_issue_template,
)


def main() -> None:
    for task in TASKS:
        result = task()
        if result is not None:
            print(json.dumps(result.__dict__, ensure_ascii=False))
            return

    print(
        json.dumps(
            TaskResult(
                status="skipped",
                title="No suitable maintenance task",
                commit_message="",
                changed_files=[],
                reason="All predefined small maintenance improvements are already present.",
            ).__dict__,
            ensure_ascii=False,
        )
    )


if __name__ == "__main__":
    main()
