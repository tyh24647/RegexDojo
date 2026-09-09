//
//  RegexDojoApp.swift
//  RegexDojo
//
//  Application entry point and debug-time curriculum validation.
//
//  Created by Tyler Hostager on 2026-09-09.
//  Copyright © 2026 Tyler Hostager. All rights reserved.
//

import SwiftUI

/// RegexDojo application entry point and shared dependency container.
@main
struct RegexDojoApp: App {
    @StateObject private var progress = ProgressStore()
    @StateObject private var settings = AppSettings()
    @StateObject private var router = CourseRouter()

    init() {
        #if DEBUG
            CourseValidation.validateBundledSolutions()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(progress)
                .environmentObject(settings)
                .environmentObject(router)
                .task {
                    progress.setICloudSyncEnabled(settings.iCloudSyncEnabled)
                }
                .onChange(of: settings.iCloudSyncEnabled) { _, enabled in
                    progress.setICloudSyncEnabled(enabled)
                }
        }
    }
}

private enum CourseValidation {
    /// Debug-only integrity check that compiles every reference solution and verifies its test corpus.
    ///
    /// Keeping this validation close to application startup catches malformed course
    /// data immediately during development instead of allowing an impossible exercise
    /// to ship unnoticed.
    static func validateBundledSolutions() {
        precondition(CourseCatalog.lessons.count == 25, "Expected 25 lessons")
        precondition(CourseCatalog.totalExerciseCount >= 120, "Expected at least 120 exercises")

        for lesson in CourseCatalog.lessons {
            for exercise in lesson.exercises {
                let result = RegexEngine.evaluate(pattern: exercise.solution, exercise: exercise)
                if !result.allPassed {
                    let reason = result.compileError ?? "test mismatch"
                    print("⚠️ Bundled solution failed validation: \(exercise.id) — \(reason)")
                }
            }
        }
    }
}
