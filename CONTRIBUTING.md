# Contributing to Seizewell

Thank you for helping. Seizewell is used in frightening moments by people
who are not thinking about software, so the bar is: **calm, fast, private,
and correct**.

## Ground rules

- **No network code, analytics, ads or trackers.** Pull requests that add a
  dependency which phones home will not be merged. The release workflow
  fails if the Android app gains the `INTERNET` permission.
- **The Start button must always work** — locked, offline, first launch,
  low battery.
- Seizewell is a diary, **not a medical device**: it records and reports; it
  does not diagnose or advise beyond the user's own emergency plan.
- Plain language over medical jargon; accessibility labels on everything.

## Development

Requirements: Flutter 3.50 (stable), Android Studio or Xcode for running on
a device.

```bash
flutter pub get
flutter run
```

The database schema lives in `lib/src/data/database.dart`
([drift](https://drift.simonbinder.eu/)). After changing it:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Bump `AppDatabase.currentSchemaVersion` and add a migration step for any
schema change, plus a test.

Before opening a pull request:

```bash
dart format lib test screenshots
flutter analyze --fatal-infos
flutter test
```

To refresh the screenshots in `docs/images/screens/`:

```bash
flutter test screenshots/generate_test.dart
```

## Project layout

```
lib/
  main.dart                 bootstrap: open encrypted DB, create services
  src/app.dart              root widget, lock gate, launch actions
  src/data/                 drift tables, queries, settings, demo data
  src/domain/               seizure types, emergency plan, statistics
  src/services/             notifications, backup, PDF report, CSV/FHIR, platform
  src/ui/                   screens and widgets
android/app/src/main/kotlin widget, Quick Settings tile, launch channel
test/                       unit, database and widget tests
screenshots/                screenshot generator
```

## Commit messages and releases

Write commit messages in the imperative ("Add sleep chart"). Note
user-visible changes under `## [Unreleased]` in `CHANGELOG.md`. Releases are
described in [docs/RELEASING.md](docs/RELEASING.md).

By contributing you agree that your contributions are licensed under the
GPL-3.0-or-later.
