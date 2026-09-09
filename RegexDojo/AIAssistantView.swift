//
//  AIAssistantView.swift
//  RegexDojo
//
//  On-device Foundation Models tutoring interface shown after two minutes.
//
//  Created by Tyler Hostager on 2026-09-09.
//  Copyright © 2026 Tyler Hostager. All rights reserved.
//

import FoundationModels
import SwiftUI

/// Modal chat interface for the context-aware on-device regex tutor.
struct AIAssistantView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: AppSettings

    @StateObject private var model: RegexTutorModel
    @State private var input = ""

    /// Builds a tutoring session and records a user-facing reason when the on-device model cannot run.
    init(lesson: RegexLesson, exercise: RegexExercise, currentPattern: String) {
        _model = StateObject(
            wrappedValue: RegexTutorModel(
                lesson: lesson,
                exercise: exercise,
                currentPattern: currentPattern
            )
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let unavailableReason = model.unavailableReason {
                    ContentUnavailableView(
                        "AI Tutor Unavailable",
                        systemImage: "sparkles",
                        description: Text(unavailableReason)
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(model.messages) { message in
                                    ChatBubble(message: message)
                                        .id(message.id)
                                }

                                if model.isResponding {
                                    HStack(spacing: 8) {
                                        ProgressView()
                                        Text("Thinking through the pattern…")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding()
                        }
                        .onChange(of: model.messages.count) { _, _ in
                            guard let lastID = model.messages.last?.id else {
                                return
                            }
                            withAnimation {
                                proxy.scrollTo(lastID, anchor: .bottom)
                            }
                        }
                    }

                    Divider()

                    HStack(alignment: .bottom, spacing: 10) {
                        TextField("Ask for a hint…", text: $input, axis: .vertical)
                            .lineLimit(1...5)
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.send)
                            .onSubmit {
                                sendMessage()
                            }

                        Button {
                            sendMessage()
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title)
                        }
                        .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || model.isResponding)
                        .accessibilityLabel("Send message")
                    }
                    .padding()
                }
            }
            .navigationTitle("Regex AI Tutor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .tint(settings.accentColor)
        }
    }

    private func sendMessage() {
        let message = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else {
            return
        }

        input = ""
        Task {
            await model.send(message)
        }
    }
}

private struct ChatBubble: View {
    @EnvironmentObject private var settings: AppSettings
    let message: RegexTutorModel.Message

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer(minLength: 42)
            }

            Text(message.text)
                .textSelection(.enabled)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    message.role == .user ? settings.accentColor : Color.secondary.opacity(0.14),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
                .foregroundStyle(message.role == .user ? Color.white : Color.primary)

            if message.role == .assistant {
                Spacer(minLength: 42)
            }
        }
    }
}

/// Conversation model backed by Apple Foundation Models when the system model is available.
///
/// The session receives the current lesson, learner pattern, positive/negative
/// examples, and instructor reference material so responses remain scoped to the
/// active challenge.
@MainActor
final class RegexTutorModel: ObservableObject {
    struct Message: Identifiable {
        enum Role {
            case user
            case assistant
        }

        let id = UUID()
        let role: Role
        let text: String
    }

    @Published private(set) var messages: [Message]
    @Published private(set) var isResponding = false
    @Published private(set) var unavailableReason: String?

    private var session: LanguageModelSession?

    init(lesson: RegexLesson, exercise: RegexExercise, currentPattern: String) {
        messages = [
            Message(
                role: .assistant,
                text:
                    "I can help you reason through this challenge. Tell me what part is giving you trouble, or ask me to examine your current approach."
            )
        ]

        let systemModel = SystemLanguageModel.default
        switch systemModel.availability {
        case .available:
            let requirements = exercise.requiredMatches.map { value in
                "• Must match: \(value)"
            }
            .joined(separator: "\n")

            let rejections = exercise.mustNotMatch.map { value in
                "• Must reject: \(value)"
            }
            .joined(separator: "\n")

            let instructions = """
                You are the built-in RegexDojo tutor. Teach regular expressions accurately and concisely.
                Guide the learner with explanation, questions, and incremental hints rather than immediately dumping the final answer.
                You may reveal the exact solution if the learner explicitly asks for it or clearly cannot progress after guided help.
                Explain engine differences when relevant. RegexDojo executes NSRegularExpression / ICU syntax.

                Current lesson: \(lesson.number) — \(lesson.title)
                Lesson concepts: \(lesson.concepts.joined(separator: ", "))
                Exercise: \(exercise.title)
                Prompt: \(exercise.prompt)
                Match mode: \(exercise.matchMode.title)
                Current learner regex: \(currentPattern.isEmpty ? "(empty)" : currentPattern)

                Test requirements:
                \(requirements)
                \(rejections.isEmpty ? "• No explicit rejection cases." : rejections)

                Instructor reference solution: \(exercise.solution)
                Instructor explanation: \(exercise.explanation)
                """

            session = LanguageModelSession(instructions: instructions)

        case .unavailable(.appleIntelligenceNotEnabled):
            unavailableReason =
                "Apple Intelligence is turned off. Enable it in Settings to use the on-device RegexDojo tutor."

        case .unavailable(.deviceNotEligible):
            unavailableReason =
                "This device does not support the on-device Apple Foundation Model required by RegexDojo's AI tutor."

        case .unavailable(.modelNotReady):
            unavailableReason =
                "The on-device model is not ready yet. iOS may still be downloading or preparing Apple Intelligence resources."

        case .unavailable:
            unavailableReason = "The on-device Apple Foundation Model is currently unavailable."

        @unknown default:
            unavailableReason = "The on-device Apple Foundation Model is currently unavailable."
        }
    }

    /// Sends one learner turn to the current model session and appends the response to the transcript.
    func send(_ text: String) async {
        guard let session, !isResponding else {
            return
        }

        messages.append(Message(role: .user, text: text))
        isResponding = true
        defer {
            isResponding = false
        }

        do {
            let response = try await session.respond(to: text)
            messages.append(Message(role: .assistant, text: response.content))
        } catch {
            messages.append(
                Message(
                    role: .assistant,
                    text: "I couldn't generate a response this time: \(error.localizedDescription)"
                )
            )
        }
    }
}
