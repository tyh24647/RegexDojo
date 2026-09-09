# RegexDojo IPA signing & device installation

**Author:** Tyler Hostager (`tyh24647@gmail.com`)  
**Date:** 2026-09-09

Configured defaults:

- Apple Developer Team ID: `3ZFSS4SN58`
- Bundle ID: `com.tyh24647.RegexDojo`
- Test-device UDID: `00008150-000579EE3E40401C`

This folder builds development or Ad Hoc IPAs on a Mac with Xcode and the matching Apple signing identity installed in Keychain.

## Development IPA

```sh
./Signing/build-ipa.sh development
```

## Ad Hoc / release-testing IPA

```sh
./Signing/build-ipa.sh adhoc
```

The values above are defaults; `TEAM_ID`, `BUNDLE_ID`, and other supported environment variables can still override them for another team/build.

## Install on the configured iPhone

```sh
./Signing/install-ipa.sh build/signing/development/RegexDojo-development.ipa
```

The installer defaults to UDID `00008150-000579EE3E40401C`. Pass another device identifier as the optional second argument to override it.

## Provisioning profile vs configuration profile

The install authorization is the `.mobileprovision` embedded in the signed application. A `.mobileconfig` configuration profile does not substitute for code signing.

## Inspect a signed IPA

```sh
./Signing/inspect-ipa.sh build/signing/adhoc/RegexDojo-adhoc.ipa
```

The inspector displays the bundle identifier, code-signing team, signed entitlements, provisioning profile, expiration, and registered device identifiers.
