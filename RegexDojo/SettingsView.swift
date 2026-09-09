//
//  SettingsView.swift
//  RegexDojo
//
//  User-facing customization, sync, support, resources, and app information.
//
//  Created by Tyler Hostager on 2026-09-09.
//  Copyright © 2026 Tyler Hostager. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

/// User-facing controls for appearance, fonts, synchronization, support, and app information.
struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var progress: ProgressStore

    @State private var showFontImporter = false
    @State private var fontImportMessage: String?
    @State private var showResetConfirmation = false

    private let trueTypeFont = UTType(filenameExtension: "ttf") ?? .data
    private let openTypeFont = UTType(filenameExtension: "otf") ?? .data

    var body: some View {
        Form {
            appearanceSection
            fontSection
            dataSection
            supportSection
            aboutSection
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .fileImporter(
            isPresented: $showFontImporter,
            allowedContentTypes: [trueTypeFont, openTypeFont],
            allowsMultipleSelection: false
        ) { result in
            importFont(result)
        }
        .confirmationDialog(
            "Reset RegexDojo progress?",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset Progress", role: .destructive) {
                progress.resetAllProgress()
            }
        } message: {
            Text(
                "This clears completed exercises, regex drafts, XP, and lesson timers so you can retake the course from the beginning. Your appearance settings stay unchanged."
            )
        }
        .onChange(of: settings.iCloudSyncEnabled) { _, isEnabled in
            progress.setICloudSyncEnabled(isEnabled)
        }
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Font Size")
                    Spacer()
                    Text(settings.fontSizeLabel)
                        .foregroundStyle(.secondary)
                }

                Slider(
                    value: Binding(
                        get: {
                            Double(settings.fontSizeStep)
                        },
                        set: { value in
                            settings.fontSizeStep = Int(value.rounded())
                        }
                    ),
                    in: 0...6,
                    step: 1
                ) {
                    Text("Font Size")
                } minimumValueLabel: {
                    Image(systemName: "textformat.size.smaller")
                } maximumValueLabel: {
                    Image(systemName: "textformat.size.larger")
                }
            }

            Picker("Theme", selection: $settings.appearanceMode) {
                ForEach(AppSettings.AppearanceMode.allCases) { mode in
                    Text(mode.title)
                        .tag(mode)
                }
            }
            .pickerStyle(.segmented)

            VStack(alignment: .leading, spacing: 12) {
                Text("Accent Color")

                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4),
                    spacing: 12
                ) {
                    ForEach(AppSettings.AccentPreset.allCases) { preset in
                        Button {
                            settings.accentPreset = preset
                            settings.accentMode = .preset
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(preset.color)
                                    .frame(width: 40, height: 40)

                                if settings.accentMode == .preset && settings.accentPreset == preset {
                                    Image(systemName: "checkmark")
                                        .font(.headline.bold())
                                        .foregroundStyle(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .accessibilityLabel(preset.title)
                        }
                        .buttonStyle(.plain)
                    }
                }

                ColorPicker(
                    "Custom Accent",
                    selection: Binding(
                        get: {
                            settings.customAccentColor
                        },
                        set: { color in
                            settings.customAccentColor = color
                        }
                    ),
                    supportsOpacity: false
                )
            }
        }
    }

    private var fontSection: some View {
        Section("Regex Font") {
            Picker("Monospaced Font", selection: $settings.monospacedFont) {
                ForEach(AppSettings.MonospacedFontChoice.allCases) { font in
                    if font != .imported || settings.importedFontPostScriptName != nil {
                        Text(font.title)
                            .tag(font)
                    }
                }
            }

            Button {
                showFontImporter = true
            } label: {
                Label("Import TTF or OTF Font", systemImage: "square.and.arrow.down")
            }

            if let name = settings.importedFontPostScriptName {
                LabeledContent("Imported Font", value: name)
            }

            if let fontImportMessage {
                Text(fontImportMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("Custom fonts are copied into RegexDojo's app documents and registered only for this app.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var dataSection: some View {
        Section("Data") {
            Toggle(isOn: $settings.iCloudSyncEnabled) {
                Label("Sync Progress with iCloud", systemImage: "icloud")
            }

            if settings.iCloudSyncEnabled {
                Button("Sync Now") {
                    progress.synchronizeNow()
                    settings.synchronizeNow()
                }

                if let message = settings.iCloudStatusMessage ?? progress.iCloudStatusMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Button(role: .destructive) {
                showResetConfirmation = true
            } label: {
                Label("Reset App Progress", systemImage: "arrow.counterclockwise")
            }
        }
    }

    private var supportSection: some View {
        Section("Support & Study") {
            Link(destination: Self.bugReportURL) {
                Label("Send a Bug Report", systemImage: "ladybug")
            }

            NavigationLink {
                RegexResourcesView()
            } label: {
                Label("Regex Resources", systemImage: "books.vertical")
            }

            Link(destination: URL(string: "https://tylero056.com")!) {
                Label("Developer Website", systemImage: "globe")
            }

            Link(destination: URL(string: "https://www.github.com/tyh24647")!) {
                Label("Developer GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
            }
        }
    }

    private var aboutSection: some View {
        Section("About") {
            NavigationLink("About RegexDojo") {
                AboutView()
            }

            NavigationLink("Acknowledgements & Licenses") {
                AcknowledgementsView()
            }
        }
    }

    /// Handles document-picker font selection and surfaces registration errors to the user.
    private func importFont(_ result: Result<[URL], Error>) {
        do {
            guard let url = try result.get().first else {
                return
            }
            let imported = try FontManager.shared.importFont(from: url)
            settings.useImportedFont(
                postScriptName: imported.postScriptName,
                fileName: imported.fileName
            )
            fontImportMessage = "Using \(imported.postScriptName)."
        } catch {
            fontImportMessage = error.localizedDescription
        }
    }

    private static var bugReportURL: URL {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = "tyh24647@gmail.com"
        components.queryItems = [
            URLQueryItem(name: "subject", value: "RegexDojo Bug Report"),
            URLQueryItem(
                name: "body",
                value:
                    "Please describe the issue below.\n\nApp: RegexDojo\nVersion: \(Bundle.main.appVersionDescription)\n\nSteps to reproduce:\n1. \n2. \n3. \n\nExpected result:\n\nActual result:\n"
            ),
        ]
        return components.url ?? URL(string: "mailto:tyh24647@gmail.com")!
    }
}

private struct RegexResourcesView: View {
    var body: some View {
        List {
            Section("Interactive Practice") {
                resource(
                    "regex101",
                    subtitle: "Interactive tester and debugger for PCRE2 and other engines.",
                    url: "https://regex101.com"
                )
                resource(
                    "Regular-Expressions.info",
                    subtitle: "Detailed tutorials and cross-engine explanations.",
                    url: "https://www.regular-expressions.info"
                )
            }

            Section("Engine References") {
                resource(
                    "ICU Regular Expressions",
                    subtitle: "Syntax reference closest to NSRegularExpression's runtime behavior.",
                    url: "https://unicode-org.github.io/icu/userguide/strings/regexp.html"
                )
                resource(
                    "PCRE2 Pattern Reference",
                    subtitle: "Reference for advanced PCRE2 features including recursion.",
                    url: "https://www.pcre.org/current/doc/html/pcre2pattern.html"
                )
                resource(
                    "Apple NSRegularExpression",
                    subtitle: "Apple's Foundation regular-expression API documentation.",
                    url: "https://developer.apple.com/documentation/foundation/nsregularexpression"
                )
            }
        }
        .navigationTitle("Regex Resources")
    }

    private func resource(_ title: String, subtitle: String, url: String) -> some View {
        Link(destination: URL(string: url)!) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("RegexDojo")
                        .font(.largeTitle.bold())
                    Text("Version \(Bundle.main.appVersionDescription)")
                        .foregroundStyle(.secondary)
                    Text(
                        "A progressive, hands-on course for learning regular expressions by making real test cases pass."
                    )
                }
                .padding(.vertical, 8)
            }

            Section("Developer") {
                LabeledContent("Author", value: "Tyler Hostager")
                Link("tylero056.com", destination: URL(string: "https://tylero056.com")!)
                Link("github.com/tyh24647", destination: URL(string: "https://www.github.com/tyh24647")!)
            }

            Section("Copyright") {
                Text("Copyright © 2026 Tyler Hostager. All rights reserved.")
            }
        }
        .navigationTitle("About")
    }
}

private struct AcknowledgementsView: View {
    var body: some View {
        List {
            Section("Third-Party Libraries") {
                Text(
                    "RegexDojo currently has no bundled third-party package dependencies. The course and application code use Apple platform frameworks only."
                )
            }

            Section("Apple Frameworks") {
                acknowledgement(
                    "SwiftUI", details: "User interface, navigation, sharing, rendering, and system appearance.")
                acknowledgement(
                    "Foundation", details: "Persistence, regular expressions, URLs, and iCloud key-value storage.")
                acknowledgement(
                    "Foundation Models", details: "On-device AI tutoring when Apple Intelligence is available.")
                acknowledgement("CoreText", details: "Runtime registration of user-imported TTF and OTF fonts.")
                acknowledgement("UIKit", details: "Dynamic system colors and image interoperability.")
                acknowledgement("Uniform Type Identifiers", details: "Safe selection of supported font files.")
            }

            Section("Licensing") {
                Text(
                    "Apple frameworks and SDK components are provided under Apple's applicable SDK and developer agreements and are not redistributed as third-party source libraries by this project."
                )
                Text(
                    "RegexDojo application code and course content: Copyright © 2026 Tyler Hostager. All rights reserved."
                )
            }
        }
        .navigationTitle("Acknowledgements")
    }

    private func acknowledgement(_ title: String, details: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.headline)
            Text(details)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 3)
    }
}

extension Bundle {
    fileprivate var appVersionDescription: String {
        let version = object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }
}
