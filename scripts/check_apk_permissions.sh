#!/usr/bin/env bash
# Fails if a release APK requests a permission Seizewell must never have.
# Usage: scripts/check_apk_permissions.sh path/to/app.apk
set -euo pipefail

apk="${1:?usage: $0 app.apk}"
sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
aapt2="$(ls -d "$sdk"/build-tools/*/aapt2 2>/dev/null | sort -V | tail -1)"
if [[ -z "$aapt2" ]]; then
  echo "aapt2 not found under \$ANDROID_HOME/build-tools" >&2
  exit 2
fi

perms="$("$aapt2" dump permissions "$apk")"
echo "$perms"

forbidden=(
  android.permission.INTERNET
  android.permission.ACCESS_NETWORK_STATE
  android.permission.READ_CONTACTS
  android.permission.ACCESS_FINE_LOCATION
  android.permission.ACCESS_COARSE_LOCATION
  android.permission.READ_EXTERNAL_STORAGE
  android.permission.CAMERA
  android.permission.RECORD_AUDIO
)
status=0
for p in "${forbidden[@]}"; do
  if grep -q "name='$p'" <<<"$perms"; then
    echo "::error::$apk requests forbidden permission $p"
    status=1
  fi
done
[[ $status -eq 0 ]] && echo "OK: no network or other forbidden permissions."
exit $status
