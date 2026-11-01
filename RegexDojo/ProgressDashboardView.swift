//
//  ProgressDashboardView.swift
//  RegexDojo
//
//  Course-completion metrics, lesson map, and progress reset controls.
//
//  Created by Tyler Hostager on 2026-09-09.
//  Copyright © 2026 Tyler Hostager. All rights reserved.
//

import SwiftUI

/// Summarizes course completion, XP, and per-lesson progress.
struct ProgressDashboardView: View {
    @EnvironmentObject private var progress: ProgressStore
    @State private var confirmReset = false

    private var completedLessons: Int {
        CourseCatalog.lessons.filter { lesson in
            progress.isLessonCompleted(lesson)
        }
        .count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Your Progress")
                    .font(.largeTitle.bold())

                Card {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("\(Int(progress.progressFraction * 100))%")
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                            Spacer()
                            Text("\(progress.xp) XP")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        ProgressView(value: progress.progressFraction)
                        Text("\(progress.completedCount) of \(progress.totalCount) exercises completed")
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 12) {
                    MetricCard(value: "\(completedLessons)", label: "Lessons finished")
                    MetricCard(value: "\(25 - completedLessons)", label: "Lessons remaining")
                }

                Card {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Course map")
                            .font(.headline)

                        ForEach(CourseCatalog.lessons) { lesson in
                            HStack {
                                Image(
                                    systemName: progress.isLessonCompleted(lesson) ? "checkmark.circle.fill" : "circle"
                                )
                                .foregroundStyle(progress.isLessonCompleted(lesson) ? .green : .secondary)
                                Text("\(lesson.number). \(lesson.title)")
                                Spacer()
                                Text("\(progress.completedCount(in: lesson))/5")
                                    .foregroundStyle(.secondary)
                                    .monospacedDigit()
                            }
                            .font(.subheadline)

                            if lesson.id != CourseCatalog.lessons.last?.id {
                                Divider()
                            }
                        }
                    }
                }

                Button(role: .destructive) {
                    confirmReset = true
                } label: {
                    Label("Reset all progress", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .navigationTitle("Progress")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .confirmationDialog(
            "Reset all course progress?",
            isPresented: $confirmReset,
            titleVisibility: .visible
        ) {
            Button("Reset Progress", role: .destructive) {
                progress.resetAllProgress()
            }
        } message: {
            Text("Completed exercises, drafts, and solution timers will be cleared.")
        }
    }
}

private struct MetricCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
