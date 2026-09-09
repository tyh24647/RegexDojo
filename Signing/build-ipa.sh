#!/bin/bash
#
# RegexDojo signed IPA builder.
# Author: Tyler Hostager <tyh24647@gmail.com>
# Created: 2026-09-09
#
set -euo pipefail

DEFAULT_TEAM_ID="3ZFSS4SN58"
DEFAULT_BUNDLE_ID="com.tyh24647.RegexDojo"
DEFAULT_DEVICE_UDID="00008150-000579EE3E40401C"
DEVELOPER_ACCOUNT="tyh24647@gmail.com"

usage()
{
  cat <<USAGE
Build and export a signed RegexDojo IPA using the signing identities already
available to Xcode on this Mac.

Usage:
  ./Signing/build-ipa.sh development
  ./Signing/build-ipa.sh adhoc

Defaults:
  Developer account: $DEVELOPER_ACCOUNT
  Team ID:           $DEFAULT_TEAM_ID
  Bundle ID:         $DEFAULT_BUNDLE_ID
  Test device UDID:  $DEFAULT_DEVICE_UDID

Optional environment variables:
  TEAM_ID         Apple Developer Team ID (default: $DEFAULT_TEAM_ID)
  BUNDLE_ID       Bundle identifier (default: $DEFAULT_BUNDLE_ID)
  CONFIGURATION   Archive configuration (default: Release)
  OUTPUT_DIR      Output directory (default: ./build/signing/<mode>)
  CLEAN_BUILD     Set to 0 to skip xcodebuild clean (default: 1)

Modes:
  development  Development/debugging-signed IPA for registered devices.
  adhoc        Release-testing (Ad Hoc) IPA for registered devices.
USAGE
}

if [[ $# -ne 1 ]]
then
  usage
  exit 64
fi

MODE="$1"
case "$MODE" in
  development)
    EXPORT_METHOD="debugging"
    ;;
  adhoc|ad-hoc)
    MODE="adhoc"
    EXPORT_METHOD="release-testing"
    ;;
  *)
    echo "error: mode must be 'development' or 'adhoc'" >&2
    usage
    exit 64
    ;;
esac

if [[ "$(uname -s)" != "Darwin" ]]
then
  echo "error: iOS signing/export requires macOS + Xcode." >&2
  exit 69
fi

for cmd in xcodebuild xcrun security plutil unzip
do
  if ! command -v "$cmd" >/dev/null 2>&1
  then
    echo "error: required command '$cmd' was not found." >&2
    exit 69
  fi
done

TEAM_ID="${TEAM_ID:-$DEFAULT_TEAM_ID}"
BUNDLE_ID="${BUNDLE_ID:-$DEFAULT_BUNDLE_ID}"
CONFIGURATION="${CONFIGURATION:-Release}"
CLEAN_BUILD="${CLEAN_BUILD:-1}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT="$PROJECT_ROOT/RegexDojo.xcodeproj"
SCHEME="RegexDojo"

if [[ -z "${OUTPUT_DIR:-}" ]]
then
  OUTPUT_DIR="$PROJECT_ROOT/build/signing/$MODE"
fi

ARCHIVE_PATH="$OUTPUT_DIR/RegexDojo.xcarchive"
EXPORT_PATH="$OUTPUT_DIR/export"
EXPORT_OPTIONS="$OUTPUT_DIR/ExportOptions.plist"

rm -rf "$OUTPUT_DIR"
mkdir -p "$EXPORT_PATH"

cat > "$EXPORT_OPTIONS" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>${EXPORT_METHOD}</string>
    <key>destination</key>
    <string>export</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>teamID</key>
    <string>${TEAM_ID}</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>thinning</key>
    <string>&lt;none&gt;</string>
</dict>
</plist>
PLIST

XCB_ARGS=(
  -project "$PROJECT"
  -scheme "$SCHEME"
  -configuration "$CONFIGURATION"
  -destination "generic/platform=iOS"
  -archivePath "$ARCHIVE_PATH"
  -allowProvisioningUpdates
  -allowProvisioningDeviceRegistration
  DEVELOPMENT_TEAM="$TEAM_ID"
  PRODUCT_BUNDLE_IDENTIFIER="$BUNDLE_ID"
  CODE_SIGN_STYLE=Automatic
)

if [[ "$CLEAN_BUILD" == "1" ]]
then
  XCB_ARGS+=(clean)
fi
XCB_ARGS+=(archive)

printf '==> Archiving RegexDojo\n    account:    %s\n    team:       %s\n    bundle id:  %s\n    mode:       %s\n' "$DEVELOPER_ACCOUNT" "$TEAM_ID" "$BUNDLE_ID" "$MODE"
xcodebuild "${XCB_ARGS[@]}"

xcodebuild \
  -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS" \
  -allowProvisioningUpdates

IPA="$(find "$EXPORT_PATH" -maxdepth 2 -type f -name '*.ipa' -print -quit)"
if [[ -z "$IPA" ]]
then
  echo "error: export completed but no .ipa was found under $EXPORT_PATH" >&2
  exit 70
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
unzip -q "$IPA" -d "$TMP"
APP="$(find "$TMP/Payload" -maxdepth 1 -type d -name '*.app' -print -quit)"
if [[ -n "$APP" && -f "$APP/embedded.mobileprovision" ]]
then
  cp "$APP/embedded.mobileprovision" "$OUTPUT_DIR/RegexDojo-${MODE}.mobileprovision"
  security cms -D -i "$APP/embedded.mobileprovision" > "$OUTPUT_DIR/RegexDojo-${MODE}-profile.plist" 2>/dev/null || true
fi

FINAL_IPA="$OUTPUT_DIR/RegexDojo-${MODE}.ipa"
cp "$IPA" "$FINAL_IPA"

echo
echo "SUCCESS"
echo "Signed IPA: $FINAL_IPA"
echo "Default test device: $DEFAULT_DEVICE_UDID"
echo "Install: ./Signing/install-ipa.sh \"$FINAL_IPA\""
