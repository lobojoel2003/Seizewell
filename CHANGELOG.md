# Changelog

All notable changes to Seizewell are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and the project uses [Semantic Versioning](https://semver.org/).
Each release also has a build number (`version: X.Y.Z+BUILD` in
`pubspec.yaml`) that always increases; see [docs/RELEASING.md](docs/RELEASING.md).

## [Unreleased]

## [1.0.0] - 2026-11-18

The first release: a private, on-device seizure diary for patients and
caregivers.

### Added

- **One-tap seizure timer.** A huge Start button on the Today screen, the lock
  screen of the app, the Android home-screen widget, the Android Quick Settings
  tile (works from the phone's lock screen) and the app-icon shortcuts on
  Android and iOS.
- **Emergency-plan escalation.** At the plan's threshold (5 minutes by
  default) the timer turns red, vibrates and shows the family's own rescue
  medication, dose, contacts and neurologist's steps, with one-tap calling.
- **Rescue-medication timer.** "Rescue given" records the dose time and counts
  down to "call for help"; the Today screen shows when the next dose is
  allowed.
- **Background alerts.** A live stopwatch notification (an Android 16 Live
  Update where supported) and alerts at the plan's thresholds, even when the
  app is in the background.
- **Calm details later.** Seizure type (ILAE 2017-based, in plain language),
  triggers (built-in and custom), aura, during sleep, injury, emergency care,
  rescue medication and notes. Quick-logged seizures are flagged until
  details are added. "Started earlier?" and "resume timer" fix mis-taps.
- **Medications** with start, dose-change and stop history.
- **Sleep log** with hours and quality.
- **Insights:** calendar heat map, counts and median duration by type, a
  trend chart with medication changes marked, triggers, and sleep before
  seizures, over 30 days to a year.
- **One-page clinic report (PDF)** with heat map, counts by type, a timeline
  with numbered medication changes, triggers, sleep and current medications.
  US Letter or A4; share or print.
- **Exports:** CSV (seizures, medication changes, sleep) and a FHIR R4 Bundle
  (SNOMED CT–coded seizure Observations, LOINC sleep-duration Observations,
  MedicationStatements).
- **Encrypted backups** (SQLCipher, passphrase-derived key) to move to a new
  phone or keep a copy; restore replaces the diary.
- **Privacy & security:** SQLCipher-encrypted database with a random 256-bit
  key in the Android Keystore / iOS Keychain; no account, no network
  permission on Android, no analytics; Android cloud backup and device
  transfer disabled; optional biometric app lock that never blocks the
  Start button.
- Onboarding, sample data to explore, light and dark themes, accessibility
  labels and large-text support.
- CI (format, generated code, analyze, tests, Android and iOS builds, a check
  that the APK has no network permission) and tag-driven releases with
  per-ABI APKs, an AAB, an unsigned IPA and SHA-256 checksums.

[Unreleased]: https://github.com/lobojoel2003/Seizewell/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/lobojoel2003/Seizewell/releases/tag/v1.0.0
