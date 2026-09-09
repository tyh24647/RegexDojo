//
//  ProgressStore.swift
//  RegexDojo
//
//  Persists course completion, drafts, timers, XP, and optional iCloud sync.
//
//  Created by Tyler Hostager on 2026-09-09.
//  Copyright © 2026 Tyler Hostager. All rights reserved.
//

import Foundation
import SwiftUI

/// Main-actor store for learner progress, drafts, unlock timers, and optional iCloud synchronization.
@MainActor
final class ProgressStore: ObservableObject {
    /// Persisted progress snapshot shared by local storage and iCloud KVS.
    struct State: Codable {
        var completedExerciseIDs: Set<String>
        var drafts: [String: String]
        var startedAt: [String: TimeInterval]
        /// Timestamp of the most recent intentional reset, used to resolve cross-device merge conflicts.
        var resetAt: TimeInterval

        init(
            completedExerciseIDs: Set<String> = [],
            drafts: [String: String] = [:],
            startedAt: [String: TimeInterval] = [:],
            resetAt: TimeInterval = 0
        ) {
            self.completedExerciseIDs = completedExerciseIDs
            self.drafts = drafts
            self.startedAt = startedAt
            self.resetAt = resetAt
        }

        private enum CodingKeys: String, CodingKey {
            case completedExerciseIDs
            case drafts
            case startedAt
            case resetAt
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            completedExerciseIDs = try container.decodeIfPresent(Set<String>.self, forKey: .completedExerciseIDs) ?? []
            drafts = try container.decodeIfPresent([String: String].self, forKey: .drafts) ?? [:]
            startedAt = try container.decodeIfPresent([String: TimeInterval].self, forKey: .startedAt) ?? [:]
            resetAt = try container.decodeIfPresent(TimeInterval.self, forKey: .resetAt) ?? 0
        }
    }

    @Published private(set) var state: State
    @Published private(set) var iCloudStatusMessage: String?

    private let defaultsKey = "RegexDojo.Progress.v2"
    private let legacyDefaultsKey = "RegexDojo.Progress.v1"
    private let iCloudKey = "RegexDojo.Progress.v2"
    private let cloudStore = NSUbiquitousKeyValueStore.default
    private var iCloudSyncEnabled = false

    /// Required exercise time before the complete solution becomes available.
    static let solutionDelay: TimeInterval = 180
    /// Required exercise time before the AI tutor affordance appears.
    static let aiHelpDelay: TimeInterval = 120

    init() {
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
            let decoded = try? JSONDecoder().decode(State.self, from: data) {
            state = decoded
        } else if let legacyData = UserDefaults.standard.data(forKey: legacyDefaultsKey),
            let decoded = try? JSONDecoder().decode(State.self, from: legacyData) {
            state = decoded
        } else {
            state = State()
        }

        iCloudStatusMessage = nil

        NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: cloudStore,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.loadIncomingICloudState()
            }
        }
    }

    var completedCount: Int {
        state.completedExerciseIDs.count
    }

    var totalCount: Int {
        CourseCatalog.totalExerciseCount
    }

    /// Overall completion as a normalized value suitable for `ProgressView`.
    var progressFraction: Double {
        guard totalCount > 0 else {
            return 0
        }
        return Double(completedCount) / Double(totalCount)
    }

    var xp: Int {
        completedCount * 10
    }

    func isCompleted(_ exercise: RegexExercise) -> Bool {
        state.completedExerciseIDs.contains(exercise.id)
    }

    func completedCount(in lesson: RegexLesson) -> Int {
        lesson.exercises.filter { exercise in
            state.completedExerciseIDs.contains(exercise.id)
        }
        .count
    }

    func isLessonCompleted(_ lesson: RegexLesson) -> Bool {
        completedCount(in: lesson) == lesson.exercises.count
    }

    func draft(for exercise: RegexExercise) -> String {
        state.drafts[exercise.id] ?? ""
    }

    func setDraft(_ value: String, for exercise: RegexExercise) {
        state.drafts[exercise.id] = value
        save()
    }

    /// Records an exercise's first-seen timestamp without resetting an existing timer.
    func ensureStarted(_ exercise: RegexExercise) {
        guard state.startedAt[exercise.id] == nil else {
            return
        }
        state.startedAt[exercise.id] = Date().timeIntervalSince1970
        save()
    }

    /// Returns elapsed wall-clock time since the exercise was first opened.
    func elapsedSeconds(_ exercise: RegexExercise, now: Date = Date()) -> TimeInterval {
        guard let timestamp = state.startedAt[exercise.id] else {
            return 0
        }
        return max(0, now.timeIntervalSince1970 - timestamp)
    }

    /// Returns the remaining whole seconds before the solution unlocks.
    func secondsUntilSolution(_ exercise: RegexExercise, now: Date = Date()) -> Int {
        let elapsed = elapsedSeconds(exercise, now: now)
        return max(0, Int(ceil(Self.solutionDelay - elapsed)))
    }

    /// Returns the remaining whole seconds before AI help becomes available.
    func secondsUntilAIHelp(_ exercise: RegexExercise, now: Date = Date()) -> Int {
        let elapsed = elapsedSeconds(exercise, now: now)
        return max(0, Int(ceil(Self.aiHelpDelay - elapsed)))
    }

    /// Marks an exercise complete.
    ///
    /// - Returns: `true` only when the exercise was newly inserted into the completion set.
    @discardableResult
    func complete(_ exercise: RegexExercise) -> Bool {
        let inserted = state.completedExerciseIDs.insert(exercise.id).inserted
        save()
        return inserted
    }

    /// Clears course state and advances the reset timestamp so the reset can win against stale cloud data.
    func resetAllProgress() {
        state = State(resetAt: Date().timeIntervalSince1970)
        save()
    }

    /// Enables or disables cloud synchronization and performs an initial reconciliation when enabled.
    func setICloudSyncEnabled(_ enabled: Bool) {
        iCloudSyncEnabled = enabled
        guard enabled else {
            iCloudStatusMessage = nil
            return
        }

        _ = cloudStore.synchronize()
        if cloudStore.data(forKey: iCloudKey) == nil {
            pushToICloud()
        } else {
            loadIncomingICloudState()
        }
    }

    /// Pushes current progress to iCloud KVS and requests an immediate synchronization pass.
    func synchronizeNow() {
        guard iCloudSyncEnabled else {
            iCloudStatusMessage = "Enable iCloud Sync first."
            return
        }

        pushToICloud()
        let synchronized = cloudStore.synchronize()
        iCloudStatusMessage =
            synchronized
            ? "Progress sync requested." : "iCloud key-value sync is unavailable for this build or signing profile."
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(state) else {
            return
        }

        UserDefaults.standard.set(data, forKey: defaultsKey)
        if iCloudSyncEnabled {
            cloudStore.set(data, forKey: iCloudKey)
        }
    }

    private func pushToICloud() {
        guard let data = try? JSONEncoder().encode(state) else {
            return
        }
        cloudStore.set(data, forKey: iCloudKey)
    }

    /// Reconciles an incoming cloud snapshot with local progress.
    ///
    /// Reset timestamps take precedence so an intentional reset is not undone by
    /// stale completion data. When reset generations match, completion sets are
    /// unioned, non-empty local drafts win, and the earliest start timestamp is
    /// preserved so unlock timers cannot be restarted by another device.
    private func loadIncomingICloudState() {
        guard iCloudSyncEnabled,
            let data = cloudStore.data(forKey: iCloudKey),
            let incoming = try? JSONDecoder().decode(State.self, from: data)
        else {
            return
        }

        let merged: State
        if incoming.resetAt > state.resetAt {
            // A reset on another device intentionally wins over older progress.
            merged = incoming
        } else if state.resetAt > incoming.resetAt {
            // Keep the newer local reset and publish it back to iCloud.
            merged = state
        } else {
            var combined = state
            combined.completedExerciseIDs.formUnion(incoming.completedExerciseIDs)

            for (key, value) in incoming.drafts {
                if combined.drafts[key] == nil || combined.drafts[key]?.isEmpty == true {
                    combined.drafts[key] = value
                }
            }

            for (key, timestamp) in incoming.startedAt {
                if let localTimestamp = combined.startedAt[key] {
                    combined.startedAt[key] = min(localTimestamp, timestamp)
                } else {
                    combined.startedAt[key] = timestamp
                }
            }

            merged = combined
        }

        state = merged
        if let mergedData = try? JSONEncoder().encode(merged) {
            UserDefaults.standard.set(mergedData, forKey: defaultsKey)
            cloudStore.set(mergedData, forKey: iCloudKey)
        }
    }
}
