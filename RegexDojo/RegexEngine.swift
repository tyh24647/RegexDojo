//
//  RegexEngine.swift
//  RegexDojo
//
//  NSRegularExpression / ICU compile, validation, and match-range utilities.
//
//  Created by Tyler Hostager on 2026-09-09.
//  Copyright © 2026 Tyler Hostager. All rights reserved.
//

import Foundation

/// Stateless helpers for compiling and evaluating ICU-compatible regular expressions.
enum RegexEngine {
    /// Evaluates a pattern against every positive and negative test case in an exercise.
    ///
    /// - Parameters:
    ///   - pattern: The learner-supplied regular expression.
    ///   - exercise: The challenge whose match rules and test corpus should be applied.
    /// - Returns: An `EvaluationResult` containing compilation and per-case outcomes.
    static func evaluate(pattern: String, exercise: RegexExercise) -> EvaluationResult {
        guard !pattern.isEmpty else {
            return EvaluationResult(
                compileError: nil,
                required: Array(repeating: false, count: exercise.requiredMatches.count),
                rejected: Array(repeating: true, count: exercise.mustNotMatch.count)
            )
        }

        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let required = exercise.requiredMatches.map { input in
                matches(regex, input: input, mode: exercise.matchMode)
            }
            let rejected = exercise.mustNotMatch.map { input in
                !matches(regex, input: input, mode: exercise.matchMode)
            }
            return EvaluationResult(
                compileError: nil,
                required: required,
                rejected: rejected
            )
        } catch {
            return EvaluationResult(
                compileError: error.localizedDescription,
                required: Array(repeating: false, count: exercise.requiredMatches.count),
                rejected: Array(repeating: false, count: exercise.mustNotMatch.count)
            )
        }
    }

    /// Evaluates a pattern against one input using the requested match mode.
    ///
    /// - Returns: `.success(true)` when the input satisfies the pattern, `.success(false)` when it does not, or `.failure` when compilation fails.
    static func evaluate(pattern: String, input: String, mode: MatchMode) -> Result<Bool, Error> {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            return .success(matches(regex, input: input, mode: mode))
        } catch {
            return .failure(error)
        }
    }

    /// Returns the Swift string ranges of every search-style regex match in an input.
    ///
    /// Foundation reports UTF-16 `NSRange` values, so this method performs the safe conversion back to `String.Index` ranges.
    static func ranges(pattern: String, input: String) -> Result<[Range<String.Index>], Error> {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let nsRange = NSRange(input.startIndex..<input.endIndex, in: input)
            let ranges = regex.matches(in: input, range: nsRange).compactMap { result -> Range<String.Index>? in
                Range(result.range, in: input)
            }
            return .success(ranges)
        } catch {
            return .failure(error)
        }
    }

    /// Applies RegexDojo's search-vs-full-input semantics to an already compiled expression.
    private static func matches(_ regex: NSRegularExpression, input: String, mode: MatchMode) -> Bool {
        let fullRange = NSRange(input.startIndex..<input.endIndex, in: input)
        guard let result = regex.firstMatch(in: input, range: fullRange) else {
            return false
        }

        switch mode {
        case .contains:
            return true
        case .full:
            return result.range.location == fullRange.location && result.range.length == fullRange.length
        }
    }
}
