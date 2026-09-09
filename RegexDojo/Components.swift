//
//  Components.swift
//  RegexDojo
//
//  Shared visual components used throughout the RegexDojo interface.
//
//  Created by Tyler Hostager on 2026-09-09.
//  Copyright © 2026 Tyler Hostager. All rights reserved.
//

import SwiftUI

/// Reusable material-backed container used throughout the app.
struct Card<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

/// Compact capsule label for metadata and status.
struct Pill: View {
    let text: String
    var systemImage: String? = nil

    var body: some View {
        HStack(spacing: 5) {
            if let systemImage {
                Image(systemName: systemImage)
            }
            Text(text)
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.quaternary, in: Capsule())
    }
}

/// Displays one regex test input together with its current pass/fail state.
struct TestCaseRow: View {
    @EnvironmentObject private var settings: AppSettings

    let text: String
    let passed: Bool
    let shouldMatch: Bool

    private var displayText: String {
        text
            .replacingOccurrences(of: "\t", with: "⇥")
            .replacingOccurrences(of: "\n", with: "↵\n")
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(passed ? .green : .red)
                .font(.title3)

            VStack(alignment: .leading, spacing: 3) {
                Text(displayText.isEmpty ? "(empty string)" : displayText)
                    .font(settings.regexFont(size: 17))
                    .textSelection(.enabled)
                Text(shouldMatch ? "should match" : "must not match")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 5)
    }
}
