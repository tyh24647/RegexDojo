//
//  AppSettings.swift
//  RegexDojo
//
//  Application-wide appearance, font, accent-color, and sync preferences.
//
//  Created by Tyler Hostager on 2026-09-09.
//  Copyright © 2026 Tyler Hostager. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

/// Main-actor store for user-configurable appearance, typography, and settings synchronization.
@MainActor
final class AppSettings: ObservableObject {
    /// User-selected app appearance override.
    enum AppearanceMode: String, CaseIterable, Identifiable, Codable {
        case system
        case light
        case dark

        var id: String {
            rawValue
        }

        var title: String {
            switch self {
            case .system:
                return "System"
            case .light:
                return "Light"
            case .dark:
                return "Dark"
            }
        }
    }

    /// Adaptive UIKit system colors offered as curated accent presets.
    enum AccentPreset: String, CaseIterable, Identifiable, Codable {
        case blue
        case indigo
        case purple
        case pink
        case orange
        case green
        case mint
        case teal

        var id: String {
            rawValue
        }

        var title: String {
            rawValue.capitalized
        }

        var color: Color {
            switch self {
            case .blue:
                return Color(uiColor: .systemBlue)
            case .indigo:
                return Color(uiColor: .systemIndigo)
            case .purple:
                return Color(uiColor: .systemPurple)
            case .pink:
                return Color(uiColor: .systemPink)
            case .orange:
                return Color(uiColor: .systemOrange)
            case .green:
                return Color(uiColor: .systemGreen)
            case .mint:
                return Color(uiColor: .systemMint)
            case .teal:
                return Color(uiColor: .systemTeal)
            }
        }
    }

    enum AccentMode: String, Codable {
        case preset
        case custom
    }

    /// Supported built-in and imported fonts for regex/code presentation.
    enum MonospacedFontChoice: String, CaseIterable, Identifiable, Codable {
        case system
        case menlo
        case courierNew
        case courier
        case imported

        var id: String {
            rawValue
        }

        var title: String {
            switch self {
            case .system:
                return "System Mono"
            case .menlo:
                return "Menlo"
            case .courierNew:
                return "Courier New"
            case .courier:
                return "Courier"
            case .imported:
                return "Imported Font"
            }
        }
    }

    private struct StoredState: Codable {
        var appearanceMode: AppearanceMode = .system
        var accentMode: AccentMode = .preset
        var accentPreset: AccentPreset = .blue
        var customAccentHex: String = "#0A84FFFF"
        var fontSizeStep: Int = 0
        var monospacedFont: MonospacedFontChoice = .system
        var importedFontPostScriptName: String?
        var importedFontFileName: String?
        var iCloudSyncEnabled: Bool = false
    }

    @Published var appearanceMode: AppearanceMode {
        didSet {
            persist()
        }
    }

    @Published var accentMode: AccentMode {
        didSet {
            persist()
        }
    }

    @Published var accentPreset: AccentPreset {
        didSet {
            persist()
        }
    }

    @Published var customAccentHex: String {
        didSet {
            persist()
        }
    }

    @Published var fontSizeStep: Int {
        didSet {
            fontSizeStep = min(max(fontSizeStep, 0), 6)
            persist()
        }
    }

    @Published var monospacedFont: MonospacedFontChoice {
        didSet {
            persist()
        }
    }

    @Published var importedFontPostScriptName: String? {
        didSet {
            persist()
        }
    }

    @Published var importedFontFileName: String? {
        didSet {
            persist()
        }
    }

    @Published var iCloudSyncEnabled: Bool {
        didSet {
            persist()
        }
    }

    @Published private(set) var iCloudStatusMessage: String?

    private let defaultsKey = "RegexDojo.Settings.v2"
    private let iCloudKey = "RegexDojo.Settings.v2"
    private let cloudStore = NSUbiquitousKeyValueStore.default
    /// Prevents property observers from writing each field back to storage while a cloud snapshot is being applied.
    private var isApplyingExternalState = false

    init() {
        let stored: StoredState
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
            let decoded = try? JSONDecoder().decode(StoredState.self, from: data) {
            stored = decoded
        } else {
            stored = StoredState()
        }

        appearanceMode = stored.appearanceMode
        accentMode = stored.accentMode
        accentPreset = stored.accentPreset
        customAccentHex = stored.customAccentHex
        fontSizeStep = stored.fontSizeStep
        monospacedFont = stored.monospacedFont
        importedFontPostScriptName = stored.importedFontPostScriptName
        importedFontFileName = stored.importedFontFileName
        iCloudSyncEnabled = stored.iCloudSyncEnabled
        iCloudStatusMessage = nil

        if let fileName = stored.importedFontFileName {
            _ = try? FontManager.shared.registerStoredFont(fileName: fileName)
        }

        NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: cloudStore,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.loadFromICloudIfEnabled()
            }
        }

        if iCloudSyncEnabled {
            loadFromICloudIfEnabled()
        }
    }

    /// Effective accent color after resolving preset versus custom selection.
    var accentColor: Color {
        switch accentMode {
        case .preset:
            return accentPreset.color
        case .custom:
            return Color(rgbaHex: customAccentHex) ?? accentPreset.color
        }
    }

    var customAccentColor: Color {
        get {
            Color(rgbaHex: customAccentHex) ?? .blue
        }
        set {
            customAccentHex = UIColor(newValue).rgbaHexString ?? customAccentHex
            accentMode = .custom
        }
    }

    var preferredColorScheme: ColorScheme? {
        switch appearanceMode {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    /// Optional Dynamic Type override derived from the app-specific font-size slider.
    var dynamicTypeSizeOverride: DynamicTypeSize? {
        switch fontSizeStep {
        case 0:
            return nil
        case 1:
            return .small
        case 2:
            return .medium
        case 3:
            return .large
        case 4:
            return .xLarge
        case 5:
            return .xxLarge
        default:
            return .xxxLarge
        }
    }

    var fontSizeLabel: String {
        switch fontSizeStep {
        case 0:
            return "System"
        case 1:
            return "Small"
        case 2:
            return "Medium"
        case 3:
            return "Default"
        case 4:
            return "Large"
        case 5:
            return "Extra Large"
        default:
            return "Largest"
        }
    }

    /// Creates the font used for regex source and test data, honoring an imported font when available.
    func regexFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        switch monospacedFont {
        case .system:
            return .system(size: size, weight: weight, design: .monospaced)
        case .menlo:
            return .custom("Menlo", size: size).weight(weight)
        case .courierNew:
            return .custom("Courier New", size: size).weight(weight)
        case .courier:
            return .custom("Courier", size: size).weight(weight)
        case .imported:
            if let importedFontPostScriptName {
                return .custom(importedFontPostScriptName, size: size).weight(weight)
            }
            return .system(size: size, weight: weight, design: .monospaced)
        }
    }

    /// Activates a successfully registered user font and persists enough metadata to restore it on launch.
    func useImportedFont(postScriptName: String, fileName: String) {
        importedFontPostScriptName = postScriptName
        importedFontFileName = fileName
        monospacedFont = .imported
    }

    /// Writes the current settings snapshot to iCloud KVS and asks Foundation to synchronize it.
    func synchronizeNow() {
        guard iCloudSyncEnabled else {
            iCloudStatusMessage = "Enable iCloud Sync first."
            return
        }

        pushToICloud()
        let synchronized = cloudStore.synchronize()
        iCloudStatusMessage =
            synchronized ? "Sync requested." : "iCloud key-value sync is unavailable for this build or signing profile."
    }

    private func persist() {
        guard !isApplyingExternalState else {
            return
        }

        let state = makeStoredState()
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
            if iCloudSyncEnabled {
                cloudStore.set(data, forKey: iCloudKey)
            }
        }
    }

    private func pushToICloud() {
        guard let data = try? JSONEncoder().encode(makeStoredState()) else {
            return
        }
        cloudStore.set(data, forKey: iCloudKey)
    }

    /// Applies the latest iCloud settings snapshot without triggering recursive persistence writes.
    private func loadFromICloudIfEnabled() {
        guard iCloudSyncEnabled else {
            return
        }

        _ = cloudStore.synchronize()
        guard let data = cloudStore.data(forKey: iCloudKey),
            let state = try? JSONDecoder().decode(StoredState.self, from: data)
        else {
            pushToICloud()
            return
        }

        isApplyingExternalState = true
        appearanceMode = state.appearanceMode
        accentMode = state.accentMode
        accentPreset = state.accentPreset
        customAccentHex = state.customAccentHex
        fontSizeStep = state.fontSizeStep
        monospacedFont = state.monospacedFont
        importedFontPostScriptName = state.importedFontPostScriptName
        importedFontFileName = state.importedFontFileName
        iCloudSyncEnabled = state.iCloudSyncEnabled
        isApplyingExternalState = false

        if let fileName = importedFontFileName {
            _ = try? FontManager.shared.registerStoredFont(fileName: fileName)
        }

        if let localData = try? JSONEncoder().encode(makeStoredState()) {
            UserDefaults.standard.set(localData, forKey: defaultsKey)
        }
    }

    private func makeStoredState() -> StoredState {
        StoredState(
            appearanceMode: appearanceMode,
            accentMode: accentMode,
            accentPreset: accentPreset,
            customAccentHex: customAccentHex,
            fontSizeStep: fontSizeStep,
            monospacedFont: monospacedFont,
            importedFontPostScriptName: importedFontPostScriptName,
            importedFontFileName: importedFontFileName,
            iCloudSyncEnabled: iCloudSyncEnabled
        )
    }
}

extension Color {
    /// Creates an sRGB SwiftUI color from `RRGGBB` or `RRGGBBAA` hexadecimal notation.
    init?(rgbaHex: String) {
        let value = rgbaHex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard value.count == 6 || value.count == 8,
            let number = UInt64(value, radix: 16)
        else {
            return nil
        }

        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double

        if value.count == 8 {
            red = Double((number >> 24) & 0xFF) / 255.0
            green = Double((number >> 16) & 0xFF) / 255.0
            blue = Double((number >> 8) & 0xFF) / 255.0
            alpha = Double(number & 0xFF) / 255.0
        } else {
            red = Double((number >> 16) & 0xFF) / 255.0
            green = Double((number >> 8) & 0xFF) / 255.0
            blue = Double(number & 0xFF) / 255.0
            alpha = 1.0
        }

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

extension UIColor {
    /// Serializes a convertible RGB color as `#RRGGBBAA` for settings persistence.
    fileprivate var rgbaHexString: String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }

        return String(
            format: "#%02X%02X%02X%02X",
            Int(round(red * 255)),
            Int(round(green * 255)),
            Int(round(blue * 255)),
            Int(round(alpha * 255))
        )
    }
}
