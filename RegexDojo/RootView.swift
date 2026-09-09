//
//  RootView.swift
//  RegexDojo
//
//  Root tab interface and course-navigation destinations.
//
//  Created by Tyler Hostager on 2026-09-09.
//  Copyright © 2026 Tyler Hostager. All rights reserved.
//

import SwiftUI

/// Root tab interface and navigation host for the application.
struct RootView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var router: CourseRouter

    var body: some View {
        TabView {
            NavigationStack(path: $router.path) {
                CourseHomeView()
                    .navigationDestination(for: CourseRoute.self) { route in
                        destination(for: route)
                    }
            }
            .tabItem {
                Label("Learn", systemImage: "graduationcap.fill")
            }

            NavigationStack {
                PlaygroundView()
            }
            .tabItem {
                Label("Playground", systemImage: "terminal.fill")
            }

            NavigationStack {
                ProgressDashboardView()
            }
            .tabItem {
                Label("Progress", systemImage: "chart.bar.fill")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .tint(settings.accentColor)
        .preferredColorScheme(settings.preferredColorScheme)
        .modifier(DynamicTypeOverride(size: settings.dynamicTypeSizeOverride))
    }

    /// Resolves stable route identifiers back into bundled course models.
    @ViewBuilder
    private func destination(for route: CourseRoute) -> some View {
        switch route {
        case .lesson(let lessonID):
            if let lesson = CourseCatalog.lesson(id: lessonID) {
                LessonDetailView(lesson: lesson)
            } else {
                missingDestination
            }

        case .exercise(let lessonID, let exerciseID):
            if let (lesson, exercise, number) = CourseCatalog.exercise(
                lessonID: lessonID,
                exerciseID: exerciseID
            ) {
                ExerciseView(
                    lesson: lesson,
                    exercise: exercise,
                    exerciseNumber: number
                )
            } else {
                missingDestination
            }

        case .completion(let lessonID):
            if let lesson = CourseCatalog.lesson(id: lessonID) {
                LessonCompletionView(lesson: lesson)
            } else {
                missingDestination
            }
        }
    }

    private var missingDestination: some View {
        ContentUnavailableView(
            "Course Item Unavailable",
            systemImage: "questionmark.folder",
            description: Text("RegexDojo could not find this bundled lesson or exercise.")
        )
    }
}

private struct DynamicTypeOverride: ViewModifier {
    let size: DynamicTypeSize?

    @ViewBuilder
    func body(content: Content) -> some View {
        if let size {
            content.dynamicTypeSize(size)
        } else {
            content
        }
    }
}

private struct CourseHomeView: View {
    @EnvironmentObject private var progress: ProgressStore

    private var nextLesson: RegexLesson? {
        CourseCatalog.lessons.first { lesson in
            !progress.isLessonCompleted(lesson)
        }
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("RegexDojo")
                                .font(.largeTitle.bold())
                            Text("Learn regular expressions by making the tests pass.")
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(".*")
                            .font(.system(size: 28, weight: .black, design: .monospaced))
                            .padding(10)
                            .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
                    }

                    ProgressView(value: progress.progressFraction)
                    HStack {
                        Text("\(progress.completedCount) / \(progress.totalCount) exercises")
                        Spacer()
                        Text("\(progress.xp) XP")
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                    if let nextLesson {
                        NavigationLink(value: CourseRoute.lesson(nextLesson.id)) {
                            Label("Continue with Lesson \(nextLesson.number)", systemImage: "play.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.vertical, 8)
            }

            Section("25 Lessons · 125 Exercises") {
                ForEach(CourseCatalog.lessons) { lesson in
                    NavigationLink(value: CourseRoute.lesson(lesson.id)) {
                        LessonRow(lesson: lesson)
                    }
                }
            }
        }
        .navigationTitle("Course")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LessonRow: View {
    @EnvironmentObject private var progress: ProgressStore
    let lesson: RegexLesson

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        progress.isLessonCompleted(lesson) ? Color.green.opacity(0.18) : Color.secondary.opacity(0.12)
                    )
                    .frame(width: 44, height: 44)

                if progress.isLessonCompleted(lesson) {
                    Image(systemName: "checkmark")
                        .font(.headline.bold())
                        .foregroundStyle(.green)
                } else {
                    Text("\(lesson.number)")
                        .font(.headline.monospacedDigit())
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .font(.headline)
                Text(lesson.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text("\(progress.completedCount(in: lesson))/\(lesson.exercises.count) complete")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
