# Security policy

## Supported versions

Security fixes are released for the latest minor version.

| Version | Supported |
| --- | --- |
| 1.0.x | ✅ |

## Reporting a vulnerability

Please **do not open a public issue**. Use GitHub's
[private vulnerability reporting](https://github.com/lobojoel2003/Seizewell/security/advisories/new)
instead. You can expect an acknowledgement within a few days and a fix or
mitigation plan within 30 days for confirmed issues.

## Threat model

Seizewell protects a diary of health data stored on one phone.

| Threat | Protection |
| --- | --- |
| Someone copies the app's files (lost phone, backup, forensic image) | SQLCipher AES-256 database; random 256-bit key held in the Android Keystore / iOS Keychain (`…ThisDeviceOnly`) |
| Cloud or device-transfer backups | Android `allowBackup="false"` and data-extraction rules exclude all app data; the iOS key never migrates to another device |
| Network interception / server breach | No network access: the Android app has no `INTERNET` permission (verified in CI); no servers exist |
| Someone picks up the unlocked phone | Optional biometric/device-credential app lock (re-locks after 60 s in the background); the home-screen widget shows no health data |
| Lost export or backup file | Backups are SQLCipher databases keyed from a passphrase (PBKDF2-HMAC-SHA512, 256,000 iterations); exports are plain and the app says so |
| CSV formula injection | Text fields starting with `= + - @` are prefixed with `'` |

Out of scope: a compromised or rooted operating system, or an attacker who
knows the phone's unlock code.
