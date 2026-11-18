#!/usr/bin/env bash
# Prints the CHANGELOG.md section for one version (without its heading).
# Usage: scripts/changelog_section.sh 1.2.3
set -euo pipefail
version="${1:?usage: $0 VERSION}"
file="${2:-CHANGELOG.md}"
section="$(awk -v v="$version" '
  /^## \[/ {
    if (found) exit
    if (index($0, "## [" v "]") == 1) { found = 1; next }
  }
  found { print }
' "$file")"
if [[ -z "${section//[[:space:]]/}" ]]; then
  echo "No CHANGELOG entry for $version in $file" >&2
  exit 1
fi
# Drop trailing link-reference lines and blank lines.
printf '%s\n' "$section" | sed -E '/^\[[^]]+\]: /d' | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}'
