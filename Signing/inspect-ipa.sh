#!/bin/bash
#
# RegexDojo signing/provision inspection helper.
# Author: Tyler Hostager <tyh24647@gmail.com>
# Created: 2026-09-09
#
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <signed.ipa>" >&2
  exit 64
fi
IPA="$1"
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "error: provisioning-profile decoding/codesign inspection requires macOS." >&2
  exit 69
fi
if [[ ! -f "$IPA" ]]; then
  echo "error: IPA not found: $IPA" >&2
  exit 66
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
unzip -q "$IPA" -d "$TMP"
APP="$(find "$TMP/Payload" -maxdepth 1 -type d -name '*.app' -print -quit)"
if [[ -z "$APP" ]]; then
  echo "error: no .app bundle found inside IPA." >&2
  exit 65
fi

echo "== App =="
/usr/libexec/PlistBuddy -c 'Print :CFBundleDisplayName' "$APP/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Info.plist" 2>/dev/null || true

echo
echo "== Code signature =="
codesign -dv --verbose=4 "$APP" 2>&1 | grep -E '^(Identifier|TeamIdentifier|Authority|Timestamp|Format|CodeDirectory)=' || true

echo
echo "== Signed entitlements =="
codesign -d --entitlements :- "$APP" 2>/dev/null || true

PROFILE="$APP/embedded.mobileprovision"
if [[ ! -f "$PROFILE" ]]; then
  echo
echo "No embedded.mobileprovision found."
  exit 0
fi

DECODED="$TMP/profile.plist"
security cms -D -i "$PROFILE" > "$DECODED"

echo
echo "== Provisioning profile =="
for key in Name UUID TeamName ExpirationDate; do
  val="$(/usr/libexec/PlistBuddy -c "Print :$key" "$DECODED" 2>/dev/null || true)"
  [[ -n "$val" ]] && printf '%-18s %s\n' "$key:" "$val"
done

COUNT="$(/usr/libexec/PlistBuddy -c 'Print :ProvisionedDevices' "$DECODED" 2>/dev/null | grep -c '^    ' || true)"
if [[ "$COUNT" != "0" ]]; then
  printf '%-18s %s\n' 'Device entries:' "$COUNT"
  echo "Provisioned device IDs:"
  /usr/libexec/PlistBuddy -c 'Print :ProvisionedDevices' "$DECODED" 2>/dev/null || true
fi

GET_TASK_ALLOW="$(/usr/libexec/PlistBuddy -c 'Print :Entitlements:get-task-allow' "$DECODED" 2>/dev/null || true)"
if [[ -n "$GET_TASK_ALLOW" ]]; then
  printf '%-18s %s\n' 'get-task-allow:' "$GET_TASK_ALLOW"
  if [[ "$GET_TASK_ALLOW" == "true" || "$GET_TASK_ALLOW" == "1" ]]; then
    echo "Profile type hint: development/debugging"
  else
    echo "Profile type hint: release-testing / Ad Hoc"
  fi
fi
