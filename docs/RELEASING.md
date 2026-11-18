# Releasing Seizewell

Releases are built and published by GitHub Actions
([`.github/workflows/release.yml`](../.github/workflows/release.yml)) when a
version tag is pushed.

## Versions and build numbers

`pubspec.yaml` holds both numbers:

```yaml
version: 1.2.3+7
#        ^^^^^ ^
#        |     build number → Android versionCode, iOS CFBundleVersion
#        version name (Semantic Versioning) → shown to users
```

- **Version name** follows [SemVer](https://semver.org/):
  `MAJOR` for incompatible data or behaviour changes, `MINOR` for features,
  `PATCH` for fixes. Pre-releases use a suffix (`1.3.0-beta.1`) and are
  published as GitHub pre-releases.
- **Build number** increases by one for every release, never resets, and is
  what app stores use to order updates.
- Per-ABI APKs get Flutter's automatic versionCode offset
  (`1000 × ABI + build`: armeabi-v7a = 1xxx, arm64-v8a = 2xxx,
  x86_64 = 4xxx), so they can be published side by side.
- **Tags** are `v` + version name, e.g. `v1.2.3`. The release workflow fails
  if the tag and `pubspec.yaml` disagree.

## Cutting a release

```bash
scripts/bump_version.sh minor        # or patch / major / 1.4.0 / build
```

Then move the notes from `## [Unreleased]` in `CHANGELOG.md` into a new
`## [X.Y.Z] - YYYY-MM-DD` section (the workflow copies that section into the
GitHub release), commit, and tag:

```bash
git commit -am "Release 1.3.0"
git tag -a v1.3.0 -m "Seizewell 1.3.0"
git push origin main v1.3.0
```

The workflow then:

1. checks the tag against `pubspec.yaml` and extracts the changelog section;
2. runs the full CI suite (format, generated code, analyzer, tests);
3. builds per-ABI and universal APKs and an Android App Bundle, signed with
   the release key, and checks the APK has no network permission;
4. builds an unsigned iOS IPA;
5. publishes a GitHub release with all files and `SHA256SUMS.txt`.

Alternatively, without pushing a tag yourself: open **Actions → Release →
Run workflow**, pick the branch (usually `main`) and enter the tag
(`v1.3.0`). The workflow builds that branch, checks the version, and GitHub
creates the tag on the built commit when the release is published.

## Android signing

Create the keystore once, on your own computer:

```bash
scripts/create_keystore.sh            # writes seizewell-release.jks
```

Add four repository secrets (**Settings → Secrets and variables → Actions**):

| Secret | Value |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | `base64 -w0 seizewell-release.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | keystore password |
| `ANDROID_KEY_ALIAS` | `seizewell` (or the alias you chose) |
| `ANDROID_KEY_PASSWORD` | key password (same as the keystore password if you used the script) |

Back up the keystore and passwords somewhere safe. Android only installs an
update signed with the same key, so losing it means users must reinstall.

Without these secrets the workflow still publishes a release, but signs the
APKs with a throw-away debug key and says so in the release notes.

For local release builds, create `android/key.properties` (git-ignored):

```properties
storeFile=/absolute/path/to/seizewell-release.jks
storePassword=…
keyAlias=seizewell
keyPassword=…
```

## iOS

The IPA attached to releases is **unsigned**. To install it, re-sign it
with your own Apple developer account or a sideloading tool such as
AltStore. App Store distribution needs a signing certificate and
provisioning profile; add them to the workflow (for example with
`apple-actions/import-codesign-certs`) and replace `--no-codesign` with an
`flutter build ipa --export-options-plist=…` step.
