//
//  WorkoutHistoryListView.swift
//  SupplementStore
//

import SwiftUI

struct WorkoutHistoryListView: View {
    @EnvironmentObject var workoutHistory: WorkoutHistoryStore

    var body: some View {
        Group {
            if workoutHistory.sessions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 44))
                        .foregroundStyle(AppTheme.cyan.opacity(0.85))
                    Text("No sessions yet")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Finish a workout to build your history.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.65))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                List {
                    ForEach(workoutHistory.sessions) { session in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(session.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                            HStack {
                                Text("\(session.reps) reps")
                                    .foregroundStyle(.white)
                                Spacer()
                                Text("Score \(session.score)")
                                    .foregroundStyle(.white.opacity(0.88))
                            }
                            .font(.caption)
                        }
                        .listRowBackground(AppTheme.cardOverlay.opacity(0.55))
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .appStoreStyleNavigationTitle("History")
        .task {
            await workoutHistory.mergeFromServer()
        }
        .refreshable {
            await workoutHistory.mergeFromServer()
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutHistoryListView()
            .environmentObject(WorkoutHistoryStore())
    }
    .appScreenBackground()
}
