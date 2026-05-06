//
//  WorkoutAnalysisSampleBufferSink.swift
//  SupplementStore
//

import AVFoundation
import Foundation

final class WorkoutAnalysisSampleBufferSink: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    static let shared = WorkoutAnalysisSampleBufferSink()

    private let stateLock = NSLock()
    private var lastEmit = CFAbsoluteTimeGetCurrent()
    private var inFlight = false
    private let throttleSeconds: CFAbsoluteTime = 1.15

    private override init() {
        super.init()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard WorkoutAnalysisMode.isActive else { return }

        stateLock.lock()
        let elapsed = CFAbsoluteTimeGetCurrent() - lastEmit
        guard elapsed >= throttleSeconds, !inFlight else {
            stateLock.unlock()
            return
        }
        guard let jpeg = SampleBufferJPEGExporter.jpegData(from: sampleBuffer) else {
            stateLock.unlock()
            return
        }
        inFlight = true
        lastEmit = CFAbsoluteTimeGetCurrent()
        stateLock.unlock()

        let b64 = jpeg.base64EncodedString()

        Task {
            await MainActor.run { WorkoutAnalysisHub.shared.markAnalyzing() }
            do {
                let sessionId = await MainActor.run { WorkoutAnalysisHub.shared.activeCoachSessionId }
                guard let sessionId else {
                    // `start-session` may still be in flight; skip this frame without surfacing an error.
                    await MainActor.run { WorkoutAnalysisHub.shared.abortAnalyzing() }
                    self.stateLock.lock()
                    self.inFlight = false
                    self.stateLock.unlock()
                    return
                }
                let exercise = await MainActor.run { WorkoutAnalysisHub.shared.selectedExercise }
                let res = try await AIFitnessAPIService.shared.analyzeFrame(
                    sessionId: sessionId,
                    frameBase64: b64,
                    exercise: exercise
                )
                await MainActor.run {
                    WorkoutAnalysisHub.shared.applyAnalyzeResponse(res)
                }
            } catch {
                await MainActor.run {
                    WorkoutAnalysisHub.shared.setAnalyzeError(error.localizedDescription)
                }
            }
            self.stateLock.lock()
            self.inFlight = false
            self.stateLock.unlock()
        }
    }
}
