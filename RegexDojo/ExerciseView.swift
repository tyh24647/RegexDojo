//
//  ExerciseView.swift
//  RegexDojo
//
//  Interactive exercise runner with live validation, hints, timers, and AI help.
//
//  Created by Tyler Hostager on 2026-09-09.
//  Copyright © 2026 Tyler Hostager. All rights reserved.
//

import SwiftUI

/// Interactive challenge screen that evaluates the learner pattern in real time.
struct ExerciseView: View {
    @EnvironmentObject private var progress: ProgressStore
    @EnvironmentObject private var router: CourseRouter
    @EnvironmentObject private var settings: AppSettings

    let lesson: RegexLesson
    let exercise: RegexExercise
    let exerciseNumber: Int

    @State private var showHint = false
    @State private var showAIAssistant = false

    private var pattern: String {
        progress.draft(for: exercise)
    }

    private var evaluation: EvaluationResult {
        RegexEngine.evaluate(pattern: pattern, exercise: exercise)
    }

    private var patternBinding: Binding<String> {
        Binding(
            get: {
                progress.draft(for: exercise)
            },
            set: { value in
                progress.setDraft(value, for: exercise)
            }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Pill(text: "Lesson \(lesson.number)")
                    Pill(text: "\(exerciseNumber) of \(lesson.exercises.count)")
                    Spacer()
                    Pill(
                        text: exercise.matchMode.title,
                        systemImage: exercise.matchMode == .full ? "arrow.left.and.right" : "magnifyingglass"
                    )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(exercise.title)
                        .font(.largeTitle.bold())
                    Text(exercise.prompt)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Card {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Your regex", systemImage: "chevron.left.forwardslash.chevron.right")
                            .font(.headline)

                        TextField("Type a regular expression", text: patternBinding, axis: .vertical)
                            .font(settings.regexFont(size: 20))
                            .applyTextInputOptions()
                            .padding(12)
                            .background(.background.opacity(0.7), in: RoundedRectangle(cornerRadius: 12))

                        if let error = evaluation.compileError {
                            Label(error, systemImage: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundStyle(.red)
                        } else if !pattern.isEmpty {
                            Label(
                                evaluation.allPassed ? "All tests pass" : "Keep iterating",
                                systemImage: evaluation.allPassed ? "checkmark.seal.fill" : "hammer.fill"
                            )
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(evaluation.allPassed ? .green : .secondary)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Required matches")
                        .font(.headline)

                    Card {
                        VStack(spacing: 0) {
                            ForEach(Array(exercise.requiredMatches.enumerated()), id: \.offset) { index, sample in
                                TestCaseRow(
                                    text: sample,
                                    passed: evaluation.required[index],
                                    shouldMatch: true
                                )

                                if index != exercise.requiredMatches.indices.last {
                                    Divider()
                                }
                            }
                        }
                    }
                }

                if !exercise.mustNotMatch.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Reject these")
                            .font(.headline)

                        Card {
                            VStack(spacing: 0) {
                                ForEach(Array(exercise.mustNotMatch.enumerated()), id: \.offset) { index, sample in
                                    TestCaseRow(
                                        text: sample,
                                        passed: evaluation.rejected[index],
                                        shouldMatch: false
                                    )

                                    if index != exercise.mustNotMatch.indices.last {
                                        Divider()
                                    }
                                }
                            }
                        }
                    }
                }

                Button {
                    completeChallenge()
                } label: {
                    Label(
                        progress.isCompleted(exercise) ? "Completed" : "Complete challenge",
                        systemImage: progress.isCompleted(exercise) ? "checkmark.circle.fill" : "flag.checkered"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!evaluation.allPassed || progress.isCompleted(exercise))

                DisclosureGroup("Hint", isExpanded: $showHint) {
                    Text(exercise.hint)
                        .foregroundStyle(.secondary)
                        .padding(.top, 6)
                }
                .padding(14)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))

                SolutionCard(exercise: exercise)
            }
            .padding()
            .padding(.bottom, 76)
        }
        .navigationTitle("Exercise \(exerciseNumber)")
        #if os(iOS) || os(tvOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .overlay(alignment: .bottomTrailing) {
            AIHelpButton(
                exercise: exercise,
                isCompleted: progress.isCompleted(exercise),
                action: {
                    showAIAssistant = true
                }
            )
            .padding()
        }
        .sheet(isPresented: $showAIAssistant) {
            AIAssistantView(
                lesson: lesson,
                exercise: exercise,
                currentPattern: pattern
            )
            .environmentObject(settings)
        }
        .onAppear {
            progress.ensureStarted(exercise)
        }
    }

    /// Commits a passing exercise and transitions to lesson completion when the section is finished.
    private func completeChallenge() {
        guard evaluation.allPassed else {
            return
        }

        _ = progress.complete(exercise)
        if progress.isLessonCompleted(lesson) {
            router.showCompletion(for: lesson)
        }
    }
}

private extension View {
    @ViewBuilder
    func applyTextInputOptions() -> some View {
        #if os(iOS)
        if #available(iOS 15.0, *) {
            self
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
        } else {
            // Fallback for iOS versions prior to 15
            self
                .autocapitalization(.none)
        }
        #else
        // Non-iOS platforms: no-op
        self
        #endif
    }
}

private struct AIHelpButton: View {
    @EnvironmentObject private var progress: ProgressStore
    @EnvironmentObject private var settings: AppSettings

    let exercise: RegexExercise
    let isCompleted: Bool
    let action: () -> Void

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            if progress.secondsUntilAIHelp(exercise, now: context.date) == 0 && !isCompleted {
                Button(action: action) {
                    Label("Ask AI", systemImage: "sparkles")
                        .font(.headline)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(Capsule())
                .shadow(radius: 8, y: 4)
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .accessibilityHint("Opens the on-device RegexDojo tutor for this exercise")
            }
        }
        .tint(settings.accentColor)
    }
}

private struct SolutionCard: View {
    @EnvironmentObject private var progress: ProgressStore
    @EnvironmentObject private var settings: AppSettings

    let exercise: RegexExercise

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = progress.secondsUntilSolution(exercise, now: context.date)

            Card {
                VStack(alignment: .leading, spacing: 10) {
                    Label(
                        "Solution",
                        systemImage: remaining == 0 ? "lock.open.fill" : "lock.fill"
                    )
                    .font(.headline)

                    if remaining > 0 {
                        Text("Available in \(format(remaining))")
                            .font(.title3.monospacedDigit().weight(.semibold))
                        Text("The timer continues if you leave and come back to this exercise.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(exercise.solution)
                            .font(settings.regexFont(size: 20))
                            .textSelection(.enabled)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.background.opacity(0.7), in: RoundedRectangle(cornerRadius: 12))

                        Text(exercise.explanation)
                            .foregroundStyle(.secondary)

                        Button("Use solution") {
                            progress.setDraft(exercise.solution, for: exercise)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
    }

    private func format(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

