//
//  WorkoutAnalysisHub.swift
//  SupplementStore
//

import Foundation
import SwiftUI

@MainActor
final class WorkoutAnalysisHub: ObservableObject {
    static let shared = WorkoutAnalysisHub()

    @Published private(set) var repCount: Int = 0
    @Published private(set) var movementState: String = "—"
    @Published private(set) var detectedErrors: [String] = []
    @Published private(set) var lastAnalyzeError: String?
    @Published private(set) var isAnalyzing: Bool = false
    @Published var selectedExercise: String = "squat"
    /// Set after `POST /api/FitnessCoach/start-session`; required for `analyze-frame`.
    @Published private(set) var activeCoachSessionId: String?

    var formLooksGood: Bool {
        detectedErrors.isEmpty && lastAnalyzeError == nil
    }

    private init() {}

    func applyAnalyzeResponse(_ response: WorkoutAnalyzeResponse) {
        lastAnalyzeError = nil
        isAnalyzing = false
        repCount = max(repCount, response.normalizedReps)
        movementState = response.normalizedState
        let next = response.normalizedErrors
        if !next.isEmpty {
            detectedErrors = next
        }
    }

    func setAnalyzeError(_ message: String) {
        isAnalyzing = false
        lastAnalyzeError = message
    }

    func markAnalyzing() {
        isAnalyzing = true
    }

    /// Clears the analyzing flag when a frame is skipped (e.g. session not ready yet).
    func abortAnalyzing() {
        isAnalyzing = false
    }

    func resetForNewWorkout() {
        repCount = 0
        movementState = "—"
        detectedErrors = []
        lastAnalyzeError = nil
        isAnalyzing = false
        activeCoachSessionId = nil
    }

    func setActiveCoachSessionId(_ id: String?) {
        activeCoachSessionId = id
    }
}
