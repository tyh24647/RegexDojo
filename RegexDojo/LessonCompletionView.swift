//
//  LessonCompletionView.swift
//  RegexDojo
//
//  Celebrates lesson completion, creates a share card, and advances navigation.
//
//  Created by Tyler Hostager on 2026-09-09.
//  Copyright © 2026 Tyler Hostager. All rights reserved.
//

import SwiftUI

/// Celebration screen shown after all exercises in a lesson have been completed.
struct LessonCompletionView: View {
    @EnvironmentObject private var progress: ProgressStore
    @EnvironmentObject private var router: CourseRouter
    @EnvironmentObject private var settings: AppSettings

    let lesson: RegexLesson

    @State private var shareURL: URL?

    private var nextLesson: RegexLesson? {
        CourseCatalog.nextLesson(after: lesson)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                Spacer(minLength: 24)

                ZStack {
                    Circle()
                        .fill(settings.accentColor.opacity(0.16))
                        .frame(width: 128, height: 128)

                    Image(systemName: "trophy.fill")
                        .font(.system(size: 58, weight: .bold))
                        .foregroundStyle(settings.accentColor)
                }

                VStack(spacing: 8) {
                    Text("Lesson Complete!")
                        .font(.largeTitle.bold())

                    Text("Lesson \(lesson.number): \(lesson.title)")
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)

                    Text("You passed all \(lesson.exercises.count) challenges in this section.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 12) {
                    CompletionMetric(value: "+50", label: "XP")
                    CompletionMetric(value: "5/5", label: "Exercises")
                    CompletionMetric(
                        value: "\(Int(progress.progressFraction * 100))%",
                        label: "Course"
                    )
                }

                if let shareURL {
                    ShareLink(
                        item: shareURL,
                        preview: SharePreview(
                            "RegexDojo — Lesson \(lesson.number) Complete",
                            image: Image("BrandIcon")
                        )
                    ) {
                        Label("Share Achievement", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                } else {
                    Button {
                    } label: {
                        Label("Preparing Share Card…", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .disabled(true)
                }

                if let nextLesson {
                    Button {
                        router.showLesson(nextLesson)
                    } label: {
                        Label("Continue to Lesson \(nextLesson.number)", systemImage: "arrow.right")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                } else {
                    Button {
                        router.goHome()
                    } label: {
                        Label("Return to Course", systemImage: "graduationcap.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }

                Button("Back to Home") {
                    router.goHome()
                }
                .buttonStyle(.plain)
                .foregroundStyle(settings.accentColor)

                Text("Swipe back from this page to return directly to the RegexDojo course home.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .navigationTitle("Completed")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: lesson.id) {
            shareURL = await CompletionShareRenderer.makeShareImage(
                lesson: lesson,
                totalCompleted: progress.completedCount,
                totalExercises: progress.totalCount,
                accentColor: settings.accentColor
            )
        }
    }
}

private struct CompletionMetric: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

/// Renders a deterministic square achievement card and writes it to a temporary PNG for `ShareLink`.
@MainActor
private enum CompletionShareRenderer {
    /// Creates the shareable lesson-completion image off the current SwiftUI state.
    static func makeShareImage(
        lesson: RegexLesson,
        totalCompleted: Int,
        totalExercises: Int,
        accentColor: Color
    ) async -> URL? {
        let view = CompletionShareCard(
            lesson: lesson,
            totalCompleted: totalCompleted,
            totalExercises: totalExercises,
            accentColor: accentColor
        )
        .frame(width: 1080, height: 1080)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 1

        guard let image = renderer.uiImage,
            let data = image.pngData()
        else {
            return nil
        }

        let filename = "RegexDojo-Lesson-\(lesson.number)-Complete.png"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }
}

private struct CompletionShareCard: View {
    let lesson: RegexLesson
    let totalCompleted: Int
    let totalExercises: Int
    let accentColor: Color

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    accentColor.opacity(0.68),
                    Color.black,
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 38) {
                HStack(spacing: 22) {
                    Image("BrandIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("RegexDojo")
                            .font(.system(size: 54, weight: .black, design: .rounded))
                        Text("Master regular expressions")
                            .font(.system(size: 27, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.76))
                    }
                    Spacer()
                }

                Spacer()

                Image(systemName: "trophy.fill")
                    .font(.system(size: 124, weight: .bold))
                    .foregroundStyle(.yellow)

                Text("LESSON COMPLETE")
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .tracking(5)
                    .foregroundStyle(.white.opacity(0.74))

                Text("\(lesson.number). \(lesson.title)")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)

                Text("5 / 5 exercises passed")
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.82))

                HStack(spacing: 34) {
                    shareMetric("+50", label: "XP")
                    shareMetric("\(totalCompleted)/\(totalExercises)", label: "COURSE EXERCISES")
                }

                Spacer()

                Text("Patterns lead to possibilities.")
                    .font(.system(size: 26, weight: .medium, design: .serif))
                    .italic()
                    .foregroundStyle(.white.opacity(0.7))
            }
            .foregroundStyle(.white)
            .padding(70)
        }
        .clipShape(RoundedRectangle(cornerRadius: 64, style: .continuous))
    }

    private func shareMetric(_ value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 42, weight: .black, design: .rounded))
            Text(label)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.68))
        }
        .padding(.horizontal, 34)
        .padding(.vertical, 22)
        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
