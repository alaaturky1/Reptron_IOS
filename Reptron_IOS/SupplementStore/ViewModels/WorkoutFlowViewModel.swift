//
//  WorkoutFlowViewModel.swift
//  SupplementStore
//

import Foundation
import SwiftUI

@MainActor
final class WorkoutFlowViewModel: ObservableObject {
    @Published var isFinishing = false
    @Published var finishError: String?
    @Published private(set) var sessionStartError: String?

    private let api = AIFitnessAPIService.shared
    private let hub = WorkoutAnalysisHub.shared

    /// Set when `finishWorkout` runs so `onLiveSessionDisappeared` does not call `end-session` again.
    private var liveSessionFinished = false

    func startLiveSession() async {
        liveSessionFinished = false
        sessionStartError = nil
        hub.setActiveCoachSessionId(nil)
        do {
            let sid = try await api.startCoachSession()
            hub.setActiveCoachSessionId(sid)
        } catch {
            sessionStartError = error.localizedDescription
            hub.setActiveCoachSessionId(nil)
        }
    }

    /// Call when the live camera screen is dismissed without completing `finishWorkout` (e.g. Back).
    func onLiveSessionDisappeared() async {
        guard !liveSessionFinished else { return }
        guard let sid = hub.activeCoachSessionId else { return }
        let reps = hub.repCount
        let mistakes = hub.detectedErrors
        let score = max(0, min(100, 100 - mistakes.count * 10))
        try? await api.endCoachSession(sessionId: sid, reps: reps, score: score, mistakes: mistakes)
        hub.setActiveCoachSessionId(nil)
    }

    func finishWorkout(history: WorkoutHistoryStore) async -> FinishedWorkoutSummary? {
        guard !isFinishing else { return nil }
        isFinishing = true
        finishError = nil
        liveSessionFinished = true
        defer { isFinishing = false }

        let reps = hub.repCount
        let mistakes = hub.detectedErrors
        let score = max(0, min(100, 100 - mistakes.count * 10))
        let serverSid = hub.activeCoachSessionId
        let exercise = hub.selectedExercise

        let feedbackText: String
        if let sid = serverSid {
            do {
                let fb = try await api.endCoachSession(sessionId: sid, reps: reps, score: score, mistakes: mistakes)
                let t = fb?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                feedbackText = t.isEmpty ? defaultFeedback(reps: reps, score: score) : t
            } catch {
                feedbackText = defaultFeedback(reps: reps, score: score)
            }
        } else {
            feedbackText = defaultFeedback(reps: reps, score: score)
        }

        let record = WorkoutSessionRecord(
            id: UUID(),
            serverSessionId: serverSid,
            exercise: exercise,
            date: Date(),
            reps: reps,
            score: score,
            mistakes: mistakes,
            feedback: feedbackText
        )

        history.add(record)

        let summary = FinishedWorkoutSummary(record: record)
        hub.resetForNewWorkout()
        return summary
    }

    private func defaultFeedback(reps: Int, score: Int) -> String {
        "Session complete: \(reps) reps, score \(score). Focus on steady tempo and full range of motion."
    }
}
