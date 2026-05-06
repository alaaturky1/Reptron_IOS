//
//  WorkoutHistoryStore.swift
//  SupplementStore
//

import Combine
import Foundation

@MainActor
final class WorkoutHistoryStore: ObservableObject {
    @Published private(set) var sessions: [WorkoutSessionRecord] = []

    private let api = AIFitnessAPIService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        loadLocal()
        NotificationCenter.default.publisher(for: .authSessionDidChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.loadLocal()
            }
            .store(in: &cancellables)
    }

    var lastSession: WorkoutSessionRecord? {
        sessions.sorted { $0.date > $1.date }.first
    }

    private let legacyStorageKey = "workoutFitnessSessions.v1"

    private func storageKey() -> String {
        if let uid = AuthSessionManager.shared.userId, !uid.isEmpty {
            return "workoutFitnessSessions.v1.\(uid)"
        }
        return "workoutFitnessSessions.v1.guest"
    }

    func loadLocal() {
        let key = storageKey()
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([WorkoutSessionRecord].self, from: data) {
            sessions = decoded.sorted { $0.date > $1.date }
            return
        }
        if key != legacyStorageKey,
           let legacy = UserDefaults.standard.data(forKey: legacyStorageKey),
           let decoded = try? JSONDecoder().decode([WorkoutSessionRecord].self, from: legacy) {
            sessions = decoded.sorted { $0.date > $1.date }
            persist()
            UserDefaults.standard.removeObject(forKey: legacyStorageKey)
            return
        }
        sessions = []
    }

    func add(_ record: WorkoutSessionRecord) {
        sessions.removeAll { $0.id == record.id }
        sessions.insert(record, at: 0)
        persist()
    }

    func mergeFromServer() async {
        let withServerId = sessions.filter { ($0.serverSessionId ?? "").isEmpty == false }
        guard !withServerId.isEmpty else { return }
        var map = Dictionary(uniqueKeysWithValues: sessions.map { ($0.id, $0) })
        for var record in withServerId {
            guard let sid = record.serverSessionId else { continue }
            do {
                let dto = try await api.fetchSessionSummary(sessionId: sid)
                if let ex = dto.exercise, !ex.isEmpty { record.exercise = ex }
                if let r = dto.reps { record.reps = r }
                if let s = dto.avg_rep_score { record.score = Int(s.rounded()) }
                if let tally = dto.issues_tally {
                    let topMistakes = tally
                        .filter { $0.key != "visibility_low" && $0.key != "unknown_exercise" }
                        .sorted { $0.value > $1.value }
                        .prefix(3)
                        .map(\.key)
                    if !topMistakes.isEmpty { record.mistakes = topMistakes }
                }
                if let fb = dto.feedback, !fb.isEmpty { record.feedback = fb }
                map[record.id] = record
            } catch {
                // Keep existing row on failure.
            }
        }
        sessions = map.values.sorted { $0.date > $1.date }
        persist()
    }

    private func persist() {
        let key = storageKey()
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
