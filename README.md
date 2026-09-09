# RegexDojo for iOS

**Author:** Tyler Hostager  
**Developer account:** `tyh24647@gmail.com`  
**Apple Developer Team ID:** `3ZFSS4SN58`  
**Bundle identifier:** `com.tyh24647.RegexDojo`  
**Primary test device UDID:** `00008150-000579EE3E40401C`  
**Updated:** 2026-09-09

RegexDojo is a SwiftUI regular-expression learning app with **25 progressive lessons and 125 exercises**. Every exercise contains four required matches, rejection cases, live ICU/`NSRegularExpression` validation, persisted drafts and progress, hints, a three-minute solution unlock, and an optional AI tutor that appears after two minutes.

## Run it

1. Open `RegexDojo.xcodeproj` in the current Xcode release.
2. In **Signing & Capabilities**, verify the selected team is the account associated with `tyh24647@gmail.com` / Team ID `3ZFSS4SN58`.
3. Select the physical iPhone with UDID `00008150-000579EE3E40401C`, or another authorized run destination.
4. Build and run.

The project uses automatic signing and is configured for `com.tyh24647.RegexDojo`.

## Current platform target

The minimum deployment target is **iOS/iPadOS 26.0** because the built-in AI tutor uses Apple's Foundation Models framework. On iOS 27 the app automatically inherits the current system navigation/control appearance, including Liquid Glass behavior supplied by standard SwiftUI components.

## New interaction behavior

- Finishing the final outstanding exercise in a lesson completes that lesson and pushes a dedicated completion screen in from the right.
- The old lesson/exercise stack is removed before that completion screen is pushed, so an interactive swipe-back returns directly to the Course home screen.
- The completion screen renders a 1080×1080 achievement image and exposes the native share sheet.
- After two minutes in an unfinished exercise, an **Ask AI** bubble appears. It opens a modal on-device regex tutor using Apple Foundation Models when Apple Intelligence is available.
- The existing solution remains locked until three minutes have elapsed.

## Settings

The Settings tab includes:

- system/light/dark appearance
- app text-size adjustment
- dynamic system-inspired accent presets plus a custom `ColorPicker`
- monospaced font selection
- importing custom `.ttf` and `.otf` files
- optional iCloud progress/settings sync
- reset progress to retake the course
- bug-report email action
- regex study/reference links
- developer website: <https://tylero056.com>
- developer GitHub: <https://www.github.com/tyh24647>
- About, acknowledgements, and licensing information

Suggested accent choices deliberately use Apple's dynamic semantic system colors so they continue adapting across light/dark appearance and future platform changes rather than hard-coding copies of system RGB values.

## iCloud

The project contains `RegexDojo.entitlements` and enables the iCloud key-value store capability for lightweight settings and course-progress synchronization. Xcode automatic signing must provision the App ID with the corresponding iCloud capability.

The sync layer uses `NSUbiquitousKeyValueStore`; it does not store chat transcripts or other sensitive data in iCloud.

## AI tutor

`AIAssistantView.swift` uses Apple's on-device `SystemLanguageModel`/`LanguageModelSession` through Foundation Models. No API key is embedded in the application.

The tutor is intentionally given the current lesson, exercise, match/reject cases, current learner regex, explanation, and instructor reference solution. Its instructions prefer incremental tutoring and hints, while allowing the exact answer if the learner explicitly asks for it.

If Apple Intelligence is disabled, unsupported, or its model is not ready, the modal explains the availability state instead of making a network request.

## App icon and sharing artwork

`Assets.xcassets` contains the new RegexDojo icon and a reusable `BrandIcon` image. The icon uses the `/.*/` regex motif over a layered torii/mountain scene designed to remain recognizable at small icon sizes.

The same brand asset is incorporated into generated lesson-completion share cards.

## Architecture

- `RegexDojoApp.swift` — app entry point, environment stores, debug curriculum validation
- `RootView.swift` — tabs, Learn navigation stack, route destinations
- `CourseRouter.swift` — navigation-path ownership and completion transition behavior
- `CourseCatalog.swift` — bundled 25-lesson curriculum
- `Models.swift` — lesson/exercise/evaluation types
- `RegexEngine.swift` — ICU regex compile/evaluate layer
- `ProgressStore.swift` — progress, drafts, timers, XP, optional iCloud sync
- `AppSettings.swift` — appearance/accent/font/sync preferences
- `FontManager.swift` — TTF/OTF import and CoreText registration
- `LessonDetailView.swift` — lesson overview and exercises
- `ExerciseView.swift` — live challenge runner, hints, solution timer, AI bubble
- `AIAssistantView.swift` — Foundation Models tutor
- `LessonCompletionView.swift` — completion transition and share-image generation
- `PlaygroundView.swift` — free-form regex playground
- `ProgressDashboardView.swift` — completion metrics
- `SettingsView.swift` — customization, support, study links, About/licensing
- `Components.swift` — reusable visual components
- `RegexDojo.entitlements` — iCloud key-value-store entitlement
- `Assets.xcassets` — application/brand artwork

## Regex engine portability

The shipping evaluator uses `NSRegularExpression`, whose expression syntax is ICU-based. The curriculum progresses through lookarounds, backreferences, atomic groups, possessive quantifiers, Unicode, performance topics, and nested structures. The final lesson distinguishes ICU behavior from true PCRE2 recursion such as `(?R)` rather than claiming the native engine implements unsupported PCRE syntax.

## Signed IPA helpers

The `Signing/` directory contains development and Ad Hoc export helpers. Defaults are already set to Team ID `3ZFSS4SN58`, bundle identifier `com.tyh24647.RegexDojo`, and test-device UDID `00008150-000579EE3E40401C`.

See `Signing/README-SIGNING.md` for details.

## Copyright

Copyright © 2026 Tyler Hostager. All rights reserved. See `ACKNOWLEDGEMENTS.md` and `LICENSES.md` for framework/library notices.

## Source formatting and documentation

Project Swift sources use 4-space indentation and K&R/1TBS-style braces: opening braces stay on the declaration/control-flow line, executable block contents start on the next indented line, and closing braces remain on their own line. Inline executable block bodies are avoided. Non-obvious APIs, state-management rules, and algorithms use Swift DocC-compatible `///` documentation comments.

See `STYLE_GUIDE.md` for the complete project convention.
