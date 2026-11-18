#!/usr/bin/env bash
# Creates the Android release keystore and prints the values to store as
# GitHub Actions secrets. Run it once, on your own computer, and keep the
# keystore and passwords somewhere safe: losing them means users cannot
# update the app.
set -euo pipefail

out="${1:-seizewell-release.jks}"
alias="${2:-seizewell}"
if [[ -e "$out" ]]; then
  echo "$out already exists; refusing to overwrite it." >&2
  exit 1
fi

read -r -s -p "Keystore password (min. 6 characters): " password; echo
keytool -genkeypair -v \
  -keystore "$out" -storetype PKCS12 \
  -alias "$alias" -keyalg RSA -keysize 4096 -validity 10000 \
  -storepass "$password" -keypass "$password" \
  -dname "CN=Seizewell, O=Seizewell, C=US"

echo
echo "Add these repository secrets (Settings → Secrets and variables → Actions):"
echo "  ANDROID_KEYSTORE_BASE64   = output of: base64 -w0 $out   (macOS: base64 -i $out)"
echo "  ANDROID_KEYSTORE_PASSWORD = the password you just typed"
echo "  ANDROID_KEY_ALIAS         = $alias"
echo "  ANDROID_KEY_PASSWORD      = the same password"
echo
echo "With gh:  base64 -w0 $out | gh secret set ANDROID_KEYSTORE_BASE64"
