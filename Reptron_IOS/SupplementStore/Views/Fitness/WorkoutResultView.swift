//
//  WorkoutResultView.swift
//  SupplementStore
//

import SwiftUI

struct WorkoutResultView: View {
    let summary: FinishedWorkoutSummary
    var onTryAgain: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Workout complete")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 12) {
                    statRow(title: "Total reps", value: "\(summary.totalReps)", icon: "repeat")
                    statRow(title: "Score", value: "\(summary.score)", icon: "star.fill")
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.cardOverlay.opacity(0.8), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 10) {
                    Text("Detected issues")
                        .font(.headline)
                        .foregroundStyle(.white)
                    if summary.mistakes.isEmpty {
                        Text("None flagged — great job.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                    } else {
                        ForEach(summary.mistakes, id: \.self) { m in
                            Text("• \(m)")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.9))
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Coach feedback")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(summary.feedbackText)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.88))
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.cardOverlay.opacity(0.65), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                Button(action: onTryAgain) {
                    Text("Try again")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.cyan)
            }
            .padding(20)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func statRow(title: String, value: String, icon: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.85))
            Spacer()
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(.cyan)
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutResultView(
            summary: FinishedWorkoutSummary(
                record: WorkoutSessionRecord(
                    id: UUID(),
                    date: Date(),
                    reps: 12,
                    score: 88,
                    mistakes: ["Knees caving slightly"],
                    feedback: "Solid set. Control the eccentric."
                )
            ),
            onTryAgain: {}
        )
    }
    .appScreenBackground()
}
