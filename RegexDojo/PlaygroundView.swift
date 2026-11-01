//
//  PlaygroundView.swift
//  RegexDojo
//
//  Free-form ICU regular-expression playground using the selected code font.
//
//  Created by Tyler Hostager on 2026-09-09.
//  Copyright © 2026 Tyler Hostager. All rights reserved.
//

import SwiftUI

/// Free-form regex sandbox using the same evaluation engine as course exercises.
struct PlaygroundView: View {
    @EnvironmentObject private var settings: AppSettings

    @State private var pattern = "\\b\\w+@\\w+\\.\\w+\\b"
    @State private var input = "Email me at dev@example.com"
    @State private var mode: MatchMode = .contains

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Regex Playground")
                    .font(.largeTitle.bold())
                Text("Experiment outside the course with the same ICU regex engine used by the exercises.")
                    .foregroundStyle(.secondary)

                Picker("Match mode", selection: $mode) {
                    ForEach(MatchMode.allCases, id: \.self) { value in
                        Text(value.title)
                            .tag(value)
                    }
                }
                .pickerStyle(.segmented)

                Card {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pattern")
                            .font(.headline)
                        TextField("Regex", text: $pattern, axis: .vertical)
                            .font(settings.regexFont(size: 17))
                        #if os(iOS) || os(tvOS) || os(visionOS) || os(watchOS)
                            .textInputAutocapitalization(.never)
                        #endif
                            .autocorrectionDisabled()
                    }
                }

                Card {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Input")
                            .font(.headline)
                        TextEditor(text: $input)
                            .font(settings.regexFont(size: 17))
                            .frame(minHeight: 140)
                    }
                }

                PlaygroundResult(pattern: pattern, input: input, mode: mode)
            }
            .padding()
        }
        .navigationTitle("Playground")
        #if os(iOS) || os(tvOS) || os(visionOS) || os(watchOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

private struct PlaygroundResult: View {
    let pattern: String
    let input: String
    let mode: MatchMode

    var body: some View {
        let evaluation = RegexEngine.evaluate(pattern: pattern, input: input, mode: mode)

        Card {
            VStack(alignment: .leading, spacing: 8) {
                Label("Result", systemImage: "waveform.path.ecg")
                    .font(.headline)

                switch evaluation {
                case .success(let matched):
                    Label(
                        matched ? "Match" : "No match",
                        systemImage: matched ? "checkmark.circle.fill" : "xmark.circle.fill"
                    )
                    .foregroundStyle(matched ? .green : .red)

                    if case .success(let ranges) = RegexEngine.ranges(pattern: pattern, input: input) {
                        Text("\(ranges.count) match\(ranges.count == 1 ? "" : "es") found by search mode")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                case .failure(let error):
                    Label(error.localizedDescription, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                }
            }
        }
    }
}

