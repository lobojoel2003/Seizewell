#!/usr/bin/env bash
# Bumps the app version in pubspec.yaml and always increments the build
# number (Android versionCode / iOS CFBundleVersion).
#
#   scripts/bump_version.sh patch|minor|major   # 1.0.0+1 -> 1.0.1+2
#   scripts/bump_version.sh 2.0.0               # explicit version
#   scripts/bump_version.sh build               # 1.0.0+1 -> 1.0.0+2
set -euo pipefail
cd "$(dirname "$0")/.."

current="$(grep -E '^version:' pubspec.yaml | head -1 | sed 's/version: //')"
name="${current%%+*}"
build="${current##*+}"
IFS=. read -r major minor patch <<<"${name%%-*}"

case "${1:?usage: $0 patch|minor|major|build|X.Y.Z}" in
  major) name="$((major + 1)).0.0" ;;
  minor) name="$major.$((minor + 1)).0" ;;
  patch) name="$major.$minor.$((patch + 1))" ;;
  build) ;;
  *)
    if [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$ ]]; then
      name="$1"
    else
      echo "Not a semantic version: $1" >&2
      exit 1
    fi
    ;;
esac
build="$((build + 1))"

sed -i.bak -E "s/^version: .*/version: $name+$build/" pubspec.yaml && rm pubspec.yaml.bak
echo "pubspec.yaml: $current -> $name+$build"
echo "Next: add a '## [$name]' section to CHANGELOG.md, commit, then:"
echo "  git tag -a v$name -m \"Seizewell $name\" && git push origin v$name"
