//
//  AIFitnessAPIService.swift
//  SupplementStore
//

import Foundation

enum AIFitnessAPIError: LocalizedError {
    case invalidURL
    case emptyResponse
    case serverError(Int, String?)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid fitness API URL."
        case .emptyResponse: return "Empty response from fitness API."
        case .serverError(let code, let msg): return msg ?? "Server error (\(code))."
        case .decoding(let e): return e.localizedDescription
        }
    }
}

/// Typed facade over the FitnessCoach backend (`APIEndpoints.AI`).
final class AIFitnessAPIService {
    static let shared = AIFitnessAPIService()
    private static let apiKey: String? = "test-key"

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let isoFormatter: ISO8601DateFormatter

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 45
        config.timeoutIntervalForResource = 120
        session = URLSession(configuration: config)
        decoder = JSONDecoder()
        encoder = JSONEncoder()
        isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    }

    private func baseString() -> String {
        APIEndpoints.baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    private func makeRequest(path: String, method: String, body: Data?) throws -> URLRequest {
        let trimmed = path.hasPrefix("/") ? path : "/" + path
        guard let url = URL(string: baseString() + trimmed) else { throw AIFitnessAPIError.invalidURL }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        if method != "GET" {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if let token = UserDefaults.standard.string(forKey: "userToken"), !token.isEmpty {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let apiKey = Self.apiKey, !apiKey.isEmpty {
            req.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        }
        req.httpBody = body
        return req
    }

    // MARK: - FitnessCoach session API

    func startCoachSession(language: String = "en", level: String = "beginner") async throws -> String {
        let payload = ["language": language, "level": level]
        let body = try JSONSerialization.data(withJSONObject: payload)
        let respData = try await executeWithFallback(
            paths: [APIEndpoints.AI.startSession, APIEndpoints.AI.legacyStartSession],
            method: "POST",
            body: body
        )
        guard !respData.isEmpty else { throw AIFitnessAPIError.emptyResponse }
        let parsed = try decoder.decode(FitnessCoachStartSessionResponse.self, from: respData)
        guard let sid = parsed.resolvedSessionId else { throw AIFitnessAPIError.decoding(
            NSError(domain: "FitnessCoach", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing session id in response"])
        ) }
        return sid
    }

    func analyzeFrame(sessionId: String, frameBase64: String, exercise: String = "squat") async throws -> WorkoutAnalyzeResponse {
        let payload = FitnessCoachAnalyzeFrameRequest(
            session_id: sessionId,
            frame: FitnessCoachFramePayload(
                exercise: exercise,
                timestamp: Date().timeIntervalSince1970,
                image_b64: frameBase64
            )
        )
        let data = try encoder.encode(payload)
        let respData = try await executeWithFallback(
            paths: [APIEndpoints.AI.analyzeFrame, APIEndpoints.AI.legacyAnalyzeFrame],
            method: "POST",
            body: data
        )
        guard !respData.isEmpty else { throw AIFitnessAPIError.emptyResponse }
        do {
            return try decoder.decode(WorkoutAnalyzeResponse.self, from: respData)
        } catch {
            throw AIFitnessAPIError.decoding(error)
        }
    }

    /// Ends the coach session on the server. Returns optional coaching text when the API includes it.
    func endCoachSession(sessionId: String, reps: Int, score: Int, mistakes: [String]) async throws -> String? {
        let payload = FitnessCoachEndSessionRequest(session_id: sessionId)
        let data = try encoder.encode(payload)
        let respData = try await executeWithFallback(
            paths: [APIEndpoints.AI.endSession, APIEndpoints.AI.legacyEndSession],
            method: "POST",
            body: data
        )
        guard !respData.isEmpty else { return nil }
        if let parsed = try? decoder.decode(FitnessCoachEndSessionResponse.self, from: respData) {
            return parsed.resolvedFeedback
        }
        return nil
    }

    func fetchSessionSummary(sessionId: String) async throws -> FitnessCoachSessionSummaryDTO {
        let respData = try await executeWithFallback(
            paths: [APIEndpoints.AI.sessionSummary(sessionId), APIEndpoints.AI.legacySessionSummary(sessionId)],
            method: "GET",
            body: nil
        )
        guard !respData.isEmpty else { throw AIFitnessAPIError.emptyResponse }
        return try decoder.decode(FitnessCoachSessionSummaryDTO.self, from: respData)
    }

    // MARK: - Helpers

    private func executeWithFallback(paths: [String], method: String, body: Data?) async throws -> Data {
        var lastNotFoundPath: String?
        for path in paths {
            let request = try makeRequest(path: path, method: method, body: body)
            let (data, response) = try await session.data(for: request)
            if let http = response as? HTTPURLResponse, http.statusCode == 404 {
                lastNotFoundPath = path
                continue
            }
            try throwIfNeeded(response, data: data)
            return data
        }
        throw AIFitnessAPIError.serverError(404, "No matching Fitness endpoint found. Last path: \(lastNotFoundPath ?? "unknown")")
    }

    private func throwIfNeeded(_ response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200 ... 299).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8)
            throw AIFitnessAPIError.serverError(http.statusCode, msg)
        }
    }
}
