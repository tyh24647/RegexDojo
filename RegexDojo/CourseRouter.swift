//
//  CourseRouter.swift
//  RegexDojo
//
//  Central navigation coordinator for lesson, exercise, and completion flows.
//
//  Created by Tyler Hostager on 2026-09-09.
//  Copyright © 2026 Tyler Hostager. All rights reserved.
//

import SwiftUI

/// Navigation destinations in the Learn tab's course stack.
enum CourseRoute: Hashable {
    case lesson(String)
    case exercise(lessonID: String, exerciseID: String)
    case completion(String)
}

/// Coordinates course navigation so completion transitions can deliberately rebuild the stack.
@MainActor
final class CourseRouter: ObservableObject {
    @Published var path: [CourseRoute] = []

    /// Removes all pushed course destinations and returns to Course Home.
    func goHome() {
        withAnimation(.snappy) {
            path.removeAll()
        }
    }

    /// Establishes a lesson directly above Course Home, ensuring an interactive back swipe returns home.
    func showLesson(_ lesson: RegexLesson) {
        withAnimation(.snappy) {
            path = [.lesson(lesson.id)]
        }
    }

    /// Rebuilds the navigation stack and pushes a completion screen from the right.
    ///
    /// The old lesson/exercise stack is removed without animation first. After one
    /// cooperative-task yield, the completion destination is pushed normally. This
    /// preserves the native forward animation while making the back gesture return
    /// directly to Course Home.
    func showCompletion(for lesson: RegexLesson) {
        // First establish Course Home as the navigation root without animating the
        // old stack backward. Then push the completion page normally so it slides
        // in from the right and the interactive back swipe returns to Course Home.
        var resetTransaction = Transaction()
        resetTransaction.disablesAnimations = true
        withTransaction(resetTransaction) {
            path.removeAll()
        }

        Task { @MainActor in
            await Task.yield()
            withAnimation(.snappy) {
                path.append(.completion(lesson.id))
            }
        }
    }
}

extension CourseCatalog {
    /// Finds a bundled lesson by its stable curriculum identifier.
    static func lesson(id: String) -> RegexLesson? {
        lessons.first { lesson in
            lesson.id == id
        }
    }

    /// Resolves an exercise and its one-based position within a lesson.
    static func exercise(lessonID: String, exerciseID: String) -> (RegexLesson, RegexExercise, Int)? {
        guard let lesson = lesson(id: lessonID),
            let index = lesson.exercises.firstIndex(where: { exercise in
                exercise.id == exerciseID
            })
        else {
            return nil
        }

        return (lesson, lesson.exercises[index], index + 1)
    }

    /// Returns the lesson immediately following the supplied lesson, if one exists.
    static func nextLesson(after lesson: RegexLesson) -> RegexLesson? {
        guard
            let index = lessons.firstIndex(where: { candidate in
                candidate.id == lesson.id
            })
        else {
            return nil
        }

        let nextIndex = lessons.index(after: index)
        guard nextIndex < lessons.endIndex else {
            return nil
        }
        return lessons[nextIndex]
    }
}
