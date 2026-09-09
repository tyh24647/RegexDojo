#!/bin/bash
#
# RegexDojo device installer.
# Author: Tyler Hostager <tyh24647@gmail.com>
# Created: 2026-09-09
#
set -euo pipefail

DEFAULT_DEVICE="00008150-000579EE3E40401C"

if [[ $# -lt 1 || $# -gt 2 ]]
then
  echo "Usage: $0 <signed.ipa> [device-id]" >&2
  echo "Default device: $DEFAULT_DEVICE" >&2
  exit 64
fi

IPA="$1"
DEVICE="${2:-$DEFAULT_DEVICE}"

if [[ "$(uname -s)" != "Darwin" ]]
then
  echo "error: installation requires macOS with Xcode." >&2
  exit 69
fi

if [[ ! -f "$IPA" ]]
then
  echo "error: IPA not found: $IPA" >&2
  exit 66
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
unzip -q "$IPA" -d "$TMP"
APP="$(find "$TMP/Payload" -maxdepth 1 -type d -name '*.app' -print -quit)"
if [[ -z "$APP" ]]
then
  echo "error: no .app bundle found inside IPA." >&2
  exit 65
fi

BUNDLE_ID="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP/Info.plist" 2>/dev/null || true)"

echo "==> Installing $(basename "$APP") on $DEVICE"
xcrun devicectl device install app --device "$DEVICE" "$APP"

if [[ -n "$BUNDLE_ID" ]]
then
  echo "Installed bundle: $BUNDLE_ID"
  echo "Launch: xcrun devicectl device process launch --device \"$DEVICE\" \"$BUNDLE_ID\""
fi
