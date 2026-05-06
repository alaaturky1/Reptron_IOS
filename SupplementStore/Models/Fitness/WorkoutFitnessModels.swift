//
//  WorkoutFitnessModels.swift
//  SupplementStore
//

import Foundation

// MARK: - API payloads

/// POST `/api/FitnessCoach/analyze-frame`
struct FitnessCoachAnalyzeFrameRequest: Encodable {
    let session_id: String
    let frame: FitnessCoachFramePayload

    enum CodingKeys: String, CodingKey {
        case session_id
        case frame
    }
}

struct FitnessCoachFramePayload: Encodable {
    let exercise: String
    let timestamp: TimeInterval
    let image_b64: String
}

/// POST `/api/FitnessCoach/start-session` — flexible decode for common backend shapes.
struct FitnessCoachStartSessionResponse: Decodable {
    let sessionId: String?
    let session_id: String?
    let id: String?

    var resolvedSessionId: String? {
        if let sessionId, !sessionId.isEmpty { return sessionId }
        if let session_id, !session_id.isEmpty { return session_id }
        if let id, !id.isEmpty { return id }
        return nil
    }
}

/// POST `/api/FitnessCoach/end-session`
struct FitnessCoachEndSessionRequest: Encodable {
    let session_id: String

    enum CodingKeys: String, CodingKey {
        case session_id
    }
}

/// Response body from end-session (optional fields).
struct FitnessCoachEndSessionResponse: Decodable {
    let feedback: String?
    let message: String?
    let text: String?
    let summary: String?

    var resolvedFeedback: String? {
        let t = feedback ?? text ?? message ?? summary
        let trimmed = t?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }
}

/// GET `/api/FitnessCoach/session-summary/{sessionId}`
struct FitnessCoachSessionSummaryDTO: Decodable {
    let session_id: String?
    let exercise: String?
    let reps: Int?
    let avg_rep_score: Double?
    let issues_tally: [String: Int]?
    let feedback: String?
}

/// Accepts common backend shapes (camelCase or snake_case, alternate keys).
struct WorkoutAnalyzeResponse: Decodable {
    let repCount: Int?
    let rep_count: Int?
    let reps: Int?
    let state: String?
    let movementState: String?
    let movement_state: String?
    let detectedErrors: [String]?
    let detected_errors: [String]?
    let errors: [String]?
    let issues: [String]?

    var normalizedReps: Int {
        repCount ?? rep_count ?? reps ?? 0
    }

    var normalizedState: String {
        let raw = state ?? movementState ?? movement_state ?? "unknown"
        return raw.lowercased()
    }

    var normalizedErrors: [String] {
        if let issues, !issues.isEmpty { return issues }
        if let detectedErrors, !detectedErrors.isEmpty { return detectedErrors }
        if let detected_errors, !detected_errors.isEmpty { return detected_errors }
        return errors ?? []
    }
}

// MARK: - App models

struct WorkoutSessionRecord: Codable, Identifiable, Hashable {
    var id: UUID
    /// Server-side FitnessCoach session id from `start-session`, when available.
    var serverSessionId: String? = nil
    var exercise: String = "squat"
    var date: Date
    var reps: Int
    var score: Int
    var mistakes: [String]
    var feedback: String

    enum CodingKeys: String, CodingKey {
        case id, serverSessionId, exercise, date, reps, score, mistakes, feedback
    }

    init(
        id: UUID,
        serverSessionId: String? = nil,
        exercise: String = "squat",
        date: Date,
        reps: Int,
        score: Int,
        mistakes: [String],
        feedback: String
    ) {
        self.id = id
        self.serverSessionId = serverSessionId
        self.exercise = exercise
        self.date = date
        self.reps = reps
        self.score = score
        self.mistakes = mistakes
        self.feedback = feedback
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        serverSessionId = try c.decodeIfPresent(String.self, forKey: .serverSessionId)
        exercise = try c.decodeIfPresent(String.self, forKey: .exercise) ?? "squat"
        date = try c.decode(Date.self, forKey: .date)
        reps = try c.decode(Int.self, forKey: .reps)
        score = try c.decode(Int.self, forKey: .score)
        mistakes = try c.decode([String].self, forKey: .mistakes)
        feedback = try c.decode(String.self, forKey: .feedback)
    }
}

struct FinishedWorkoutSummary: Hashable {
    let id: UUID
    let date: Date
    let totalReps: Int
    let score: Int
    let mistakes: [String]
    let feedbackText: String

    init(record: WorkoutSessionRecord) {
        id = record.id
        date = record.date
        totalReps = record.reps
        score = record.score
        mistakes = record.mistakes
        feedbackText = record.feedback
    }
}
