# Privacy policy

_Last updated: 18 November 2026_

Seizewell is a seizure diary. Seizure records are among the most sensitive
health information there is, so the app is designed to collect nothing.

## What Seizewell stores

Everything you enter — seizures, triggers, medications, sleep, your
emergency plan and profile — is stored **only on your phone**, in a database
encrypted with SQLCipher (AES-256). The encryption key is generated on the
phone and kept in the Android Keystore or iOS Keychain, bound to that device.

## What Seizewell sends

Nothing. There is no account, no server, no cloud sync, no analytics, no
advertising and no crash reporting. The Android app does not request the
internet permission at all; the release workflow fails if it ever does.

Android cloud backup and device-to-device transfer are disabled for the
app's data. On iOS the database key is never synced to iCloud Keychain and
never migrates to another device, even through a backup.

## When data leaves the phone

Only when you explicitly do it:

- **Clinic report, CSV and FHIR exports** are created on the phone and handed
  to the app you choose in the share sheet. They are not encrypted; share
  them only with people you trust. Temporary copies are deleted the next
  time Seizewell starts.
- **Backups** are encrypted with a passphrase you choose. The passphrase is
  never stored.
- **Calling** a contact or emergency number opens your phone app.

## Permissions

| Permission | Why |
| --- | --- |
| Notifications | Live stopwatch and emergency-plan alerts while the timer runs |
| Exact alarms (Android) | So the 5-minute alert arrives on time |
| Biometrics | Optional app lock |
| Vibration | Alerts |

## Children

Seizewell is often used by parents for their children. No data is collected
from anyone, so no data is collected from children.

## Contact

Questions or concerns: open an issue at
<https://github.com/lobojoel2003/Seizewell/issues>, or see
[SECURITY.md](SECURITY.md) for private reports.
