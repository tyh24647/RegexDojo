//
//  LessonDetailView.swift
//  RegexDojo
//
//  Lesson overview and progressive exercise list.
//
//  Created by Tyler Hostager on 2026-09-09.
//  Copyright © 2026 Tyler Hostager. All rights reserved.
//

import SwiftUI

/// Presents lesson instruction, concepts, and links to the section exercises.
struct LessonDetailView: View {
    @EnvironmentObject private var progress: ProgressStore
    let lesson: RegexLesson

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("LESSON \(lesson.number)")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Text(lesson.title)
                        .font(.largeTitle.bold())
                    Text(lesson.subtitle)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Card {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Overview", systemImage: "book.closed.fill")
                            .font(.headline)
                        Text(lesson.overview)
                            .font(.body)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("You’ll practice")
                        .font(.headline)
                    FlowLayout(items: lesson.concepts)
                }

                if let note = lesson.advancedNote {
                    Card {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Engine note", systemImage: "gearshape.2.fill")
                                .font(.headline)
                            Text(note)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .textSelection(.enabled)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Exercises")
                            .font(.title2.bold())
                        Spacer()
                        Text("\(progress.completedCount(in: lesson))/\(lesson.exercises.count)")
                            .foregroundStyle(.secondary)
                    }

                    ForEach(Array(lesson.exercises.enumerated()), id: \.element.id) { index, exercise in
                        NavigationLink(
                            value: CourseRoute.exercise(
                                lessonID: lesson.id,
                                exerciseID: exercise.id
                            )
                        ) {
                            HStack(spacing: 12) {
                                Image(systemName: progress.isCompleted(exercise) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(progress.isCompleted(exercise) ? .green : .secondary)
                                    .font(.title3)

                                VStack(alignment: .leading, spacing: 3) {
                                    Text("\(index + 1). \(exercise.title)")
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text(exercise.matchMode.title)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.bold())
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(14)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Lesson \(lesson.number)")
#if os(iOS) || os(visionOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

private struct FlowLayout: View {
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                Label(item, systemImage: "checkmark")
                    .font(.subheadline.weight(.medium))
            }
        }
    }
}
