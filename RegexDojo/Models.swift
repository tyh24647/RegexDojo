//
//  Models.swift
//  RegexDojo
//
//  Core course, exercise, matching, and evaluation data models.
//
//  Created by Tyler Hostager on 2026-09-09.
//  Copyright © 2026 Tyler Hostager. All rights reserved.
//

import Foundation

/// Defines how RegexDojo decides whether a pattern passes a test input.
///
/// `contains` accepts any match within the input, while `full` requires the
/// first match to span the complete input string.
enum MatchMode: String, Codable, Hashable, CaseIterable {
    case contains
    case full

    /// Human-readable label used by exercise and playground interfaces.
    var title: String {
        switch self {
        case .contains:
            return "Find a match"
        case .full:
            return "Match entire input"
        }
    }
}

/// A curriculum section containing instructional material and its exercises.
struct RegexLesson: Identifiable, Codable, Hashable {
    let id: String
    let number: Int
    let title: String
    let subtitle: String
    let overview: String
    let concepts: [String]
    let exercises: [RegexExercise]
    /// Optional engine-specific or advanced material shown after the core lesson.
    let advancedNote: String?
}

/// A single regex challenge together with its positive and negative test corpus.
struct RegexExercise: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let prompt: String
    let solution: String
    let requiredMatches: [String]
    let mustNotMatch: [String]
    let hint: String
    let explanation: String
    let matchMode: MatchMode
}

/// The per-test outcome produced when evaluating a learner's pattern.
struct EvaluationResult {
    let compileError: String?
    let required: [Bool]
    let rejected: [Bool]

    /// `true` only when the pattern compiled, every required input matched, and every rejected input stayed unmatched.
    var allPassed: Bool {
        compileError == nil
            && required.allSatisfy { value in
                value
            }
            && rejected.allSatisfy { value in
                value
            }
    }
}
