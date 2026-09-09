//
//  FontManager.swift
//  RegexDojo
//
//  Imports and registers user-selected TrueType and OpenType fonts at runtime.
//
//  Created by Tyler Hostager on 2026-09-09.
//  Copyright © 2026 Tyler Hostager. All rights reserved.
//

import CoreText
import Foundation

/// Imports, stores, and process-registers user-selected TrueType/OpenType fonts.
final class FontManager {
    /// Metadata needed to select and restore an imported font later.
    struct ImportedFont {
        let postScriptName: String
        let fileName: String
    }

    static let shared = FontManager()

    private init() {
    }

    /// Copies a security-scoped font into the app container and registers it with CoreText.
    ///
    /// - Parameter sourceURL: URL returned by the document picker.
    /// - Returns: The registered PostScript name and persisted file name.
    func importFont(from sourceURL: URL) throws -> ImportedFont {
        let fileExtension = sourceURL.pathExtension.lowercased()
        guard fileExtension == "ttf" || fileExtension == "otf" else {
            throw FontManagerError.unsupportedFormat
        }

        let didAccess = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if didAccess {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }

        let fontDirectory = try fontsDirectory()
        let destinationURL = fontDirectory.appendingPathComponent(sourceURL.lastPathComponent)

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)

        let postScriptName = try registerFont(at: destinationURL)
        return ImportedFont(postScriptName: postScriptName, fileName: destinationURL.lastPathComponent)
    }

    /// Re-registers a previously imported font during a later app launch.
    @discardableResult
    func registerStoredFont(fileName: String) throws -> String {
        let url = try fontsDirectory().appendingPathComponent(fileName)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw FontManagerError.missingStoredFont
        }
        return try registerFont(at: url)
    }

    /// Registers a font for the current process and returns its PostScript name.
    ///
    /// CoreText error code 105 means the font is already registered and is treated
    /// as a successful idempotent registration.
    private func registerFont(at url: URL) throws -> String {
        var registrationError: Unmanaged<CFError>?
        let registered = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &registrationError)
        if !registered,
            let error = registrationError?.takeRetainedValue() {
            let nsError = error as Error as NSError
            if nsError.code != 105 {
                throw error
            }
        }

        guard let descriptors = CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as? [CTFontDescriptor],
            let descriptor = descriptors.first,
            let name = CTFontDescriptorCopyAttribute(descriptor, kCTFontNameAttribute) as? String
        else {
            throw FontManagerError.unreadableFontMetadata
        }

        return name
    }

    private func fontsDirectory() throws -> URL {
        let documents = try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let directory = documents.appendingPathComponent("ImportedFonts", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}

/// Errors surfaced by runtime font import and restoration.
enum FontManagerError: LocalizedError {
    case unsupportedFormat
    case unreadableFontMetadata
    case missingStoredFont

    var errorDescription: String? {
        switch self {
        case .unsupportedFormat:
            return "Choose a .ttf or .otf font file."
        case .unreadableFontMetadata:
            return "The font was copied, but RegexDojo could not read its font name."
        case .missingStoredFont:
            return "The previously imported font file is no longer available."
        }
    }
}
