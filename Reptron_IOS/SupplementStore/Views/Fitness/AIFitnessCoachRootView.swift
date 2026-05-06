//
//  AIFitnessCoachRootView.swift
//  SupplementStore
//
//  Full AI Fitness Coach flow inside the AI tab only.
//  Uses explicit phase switching so navigation works inside the outer app NavigationStack.
//

import SwiftUI

private enum AICoachPhase: Equatable {
    case home
    case liveWorkout
    case history
    case result(FinishedWorkoutSummary)
}

struct AIFitnessCoachRootView: View {
    @EnvironmentObject var workoutHistory: WorkoutHistoryStore
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var phase: AICoachPhase = .home

    var body: some View {
        Group {
            switch phase {
            case .home:
                NavigationStack {
                    AIFitnessCoachHomeView(
                        onStartWorkout: { phase = .liveWorkout },
                        onShowHistory: { phase = .history }
                    )
                    .appStoreStyleNavigationTitle("AI Coach")
                }

            case .liveWorkout:
                NavigationStack {
                    WorkoutActiveSessionView(
                        onBack: { phase = .home },
                        onFinished: { summary in
                            phase = .result(summary)
                        }
                    )
                }

            case .history:
                NavigationStack {
                    WorkoutHistoryListView()
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    phase = .home
                                } label: {
                                    Label("Back", systemImage: "chevron.left")
                                }
                            }
                        }
                }

            case .result(let summary):
                NavigationStack {
                    WorkoutResultView(summary: summary) {
                        WorkoutAnalysisHub.shared.resetForNewWorkout()
                        phase = .liveWorkout
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                phase = .home
                            } label: {
                                Label("Home", systemImage: "house.fill")
                            }
                        }
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: phase)
    }
}

// MARK: - Home (inside AI tab)

private struct AIFitnessCoachHomeView: View {
    var onStartWorkout: () -> Void
    var onShowHistory: () -> Void
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var authSession: AuthSessionManager
    @EnvironmentObject var workoutHistory: WorkoutHistoryStore
    @ObservedObject private var hub = WorkoutAnalysisHub.shared
    private let exercises = ["squat", "pushup", "plank"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header

                Button(action: onStartWorkout) {
                    Label("Start Workout", systemImage: "figure.strengthtraining.traditional")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.cyan)

                Button(action: onShowHistory) {
                    Label("Workout history", systemImage: "clock.arrow.circlepath")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.bordered)
                .tint(AppTheme.cyan.opacity(0.9))

                exercisePickerSection

                lastWorkoutSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .task {
            await workoutHistory.mergeFromServer()
        }
    }

    private var exercisePickerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Choose exercise")
                .font(.headline)
                .foregroundStyle(.white)
            HStack(spacing: 10) {
                ForEach(exercises, id: \.self) { ex in
                    let active = hub.selectedExercise == ex
                    Button {
                        hub.selectedExercise = ex
                    } label: {
                        Text(ex.capitalized)
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(active ? AppTheme.cyan : Color.white.opacity(0.2))
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greeting)
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text("AI Fitness Coach")
                .font(.subheadline)
                .foregroundStyle(Color.white.opacity(0.72))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var coachGreetingName: String {
        let n = authSession.displayName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return n.isEmpty ? "Athlete" : n
    }

    private var greeting: String {
        if userViewModel.isLoggedIn {
            return "Welcome back, \(coachGreetingName)"
        }
        return "Welcome"
    }

    @ViewBuilder
    private var lastWorkoutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last workout")
                .font(.headline)
                .foregroundStyle(.white)

            if let last = workoutHistory.lastSession {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label("\(last.reps) reps", systemImage: "repeat")
                        Spacer()
                        Label("Score \(last.score)", systemImage: "star.fill")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    Text(last.exercise.capitalized)
                        .font(.caption)
                        .foregroundStyle(.cyan.opacity(0.9))

                    Text(last.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.55))
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.cardOverlay.opacity(0.75), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                Text("Complete a workout to see your summary here.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.65))
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.cardOverlay.opacity(0.55), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }
}

// MARK: - Live session (camera + overlays)

struct WorkoutActiveSessionView: View {
    var onBack: () -> Void
    var onFinished: (FinishedWorkoutSummary) -> Void

    @StateObject private var flow = WorkoutFlowViewModel()
    @ObservedObject private var hub = WorkoutAnalysisHub.shared
    @EnvironmentObject var workoutHistory: WorkoutHistoryStore

    var body: some View {
        AICameraView()
            .overlay(alignment: .top) {
                topHUD
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
            }
            .overlay(alignment: .bottom) {
                finishButton
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }
            .appStoreStyleNavigationTitle("Workout")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onBack) {
                        Label("Back", systemImage: "chevron.left")
                    }
                }
            }
            .onAppear {
                WorkoutAnalysisMode.isActive = true
            }
            .onDisappear {
                WorkoutAnalysisMode.isActive = false
                Task { await flow.onLiveSessionDisappeared() }
            }
            .task {
                await flow.startLiveSession()
            }
    }

    @ViewBuilder
    private var topHUD: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                repChip
                stateChip
                exerciseChip
                Spacer(minLength: 0)
            }
            if !hub.detectedErrors.isEmpty {
                errorBanner
            } else if let err = hub.lastAnalyzeError {
                Text(err)
                    .font(.caption2)
                    .foregroundStyle(.orange.opacity(0.95))
                    .padding(8)
                    .background(.black.opacity(0.45), in: RoundedRectangle(cornerRadius: 10))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var repChip: some View {
        HStack(spacing: 6) {
            Text("Reps")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))
            Text("\(hub.repCount)")
                .font(.caption.bold())
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.black.opacity(0.5), in: Capsule())
        .overlay(Capsule().stroke(hub.formLooksGood ? Color.green.opacity(0.55) : Color.orange.opacity(0.65), lineWidth: 1))
    }

    private var stateChip: some View {
        HStack(spacing: 6) {
            Text("State")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))
            Text(hub.movementState)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.black.opacity(0.5), in: Capsule())
    }

    private var exerciseChip: some View {
        HStack(spacing: 6) {
            Text("Exercise")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))
            Text(hub.selectedExercise.capitalized)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.black.opacity(0.5), in: Capsule())
    }

    private var errorBanner: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Form cues")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.orange)
            ForEach(hub.detectedErrors, id: \.self) { e in
                Text("• \(e)")
                    .font(.caption2)
                    .foregroundStyle(.white)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 12))
    }

    private var finishButton: some View {
        Button {
            Task {
                if let summary = await flow.finishWorkout(history: workoutHistory) {
                    onFinished(summary)
                }
            }
        } label: {
            HStack {
                if flow.isFinishing {
                    ProgressView()
                        .tint(.white)
                }
                Text(flow.isFinishing ? "Saving…" : "Finish workout")
                    .font(.subheadline.weight(.bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .tint(AppTheme.cyan)
        .disabled(flow.isFinishing)
        .padding(.bottom, 8)
    }
}

#Preview {
    AIFitnessCoachRootView()
        .environmentObject(AuthSessionManager.shared)
        .environmentObject(WorkoutHistoryStore())
        .environmentObject(UserViewModel())
        .appScreenBackground()
}
