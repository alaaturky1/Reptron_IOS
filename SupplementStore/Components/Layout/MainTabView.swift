//
//  MainTabView.swift
//  SupplementStore
//
//  Created on [Date]
//
//  Main tab navigation for authenticated users
//  Matches React Router structure when user is logged in
//  Tabs do NOT own navigation state - navigation is handled by root NavigationStack
//

import AVFoundation
import SwiftUI
import UIKit

/// Alternate shell matching the main app tabs (used by `RootView` / `NavigationRouter`).
struct MainTabView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var workoutHistory: WorkoutHistoryStore
    @State private var selectedTab: AppTab = .home

    var body: some View {
        LayoutView(selectedTab: $selectedTab) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .store:
                    ProtectedRoute {
                        StoreView()
                    }
                case .coaches:
                    ProtectedRoute {
                        CoachesView()
                    }
                case .ai:
                    AIFitnessCoachRootView()
                case .cart:
                    ProtectedRoute {
                        CartView()
                    }
                case .profile:
                    ProfileView()
                }
            }
            .id(selectedTab)
        }
    }
}

struct AICameraView: View {
    @StateObject private var camera = LiveCameraSession()
    @Environment(\.scenePhase) private var scenePhase
    @State private var orientationRefresh = 0

    private let horizontalInset: CGFloat = 12

    var body: some View {
        GeometryReader { geo in
            let previewHeight = max(240, geo.size.height * 0.78)

            VStack(spacing: 10) {
                Text("AI")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 6)

                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.black.opacity(0.35))

                    if let message = camera.configurationError {
                        Text(message)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding()
                    } else if camera.authorizationDenied {
                        Text("Camera access is off. Enable it in Settings to use live preview.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding()
                    } else {
                        LiveCameraPreview(session: camera.session)
                            .id(orientationRefresh)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: previewHeight)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Text("Live preview · AI model integration placeholder")
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 4)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
        .padding(.horizontal, horizontalInset)
        .onAppear {
            camera.start()
        }
        .onDisappear {
            camera.stop()
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                camera.resume()
            case .inactive, .background:
                camera.stop()
            @unknown default:
                break
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            orientationRefresh += 1
        }
    }
}

// MARK: - Live camera (embedded preview)

final class LiveCameraSession: ObservableObject {
    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "supplementstore.camera.session")
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let videoDataQueue = DispatchQueue(label: "supplementstore.camera.videodata")
    private var didConfigure = false
    private var didAddVideoDataOutput = false

    @Published private(set) var authorizationDenied = false
    @Published private(set) var configurationError: String?

    func start() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            authorizationDenied = false
            configureAndRunIfNeeded()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.authorizationDenied = !granted
                }
                if granted {
                    self?.configureAndRunIfNeeded()
                }
            }
        case .denied, .restricted:
            authorizationDenied = true
        @unknown default:
            authorizationDenied = true
        }
    }

    func resume() {
        sessionQueue.async { [weak self] in
            guard let self, self.didConfigure, !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }

    private func configureAndRunIfNeeded() {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            if self.didConfigure {
                if !self.session.isRunning {
                    self.session.startRunning()
                }
                return
            }

            self.session.beginConfiguration()
            self.session.sessionPreset = .high

            for input in self.session.inputs {
                self.session.removeInput(input)
            }

            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                self.session.commitConfiguration()
                DispatchQueue.main.async {
                    self.configurationError = "No camera available on this device."
                }
                return
            }

            do {
                let input = try AVCaptureDeviceInput(device: device)
                guard self.session.canAddInput(input) else {
                    self.session.commitConfiguration()
                    DispatchQueue.main.async {
                        self.configurationError = "Could not add camera input."
                    }
                    return
                }
                self.session.addInput(input)
            } catch {
                self.session.commitConfiguration()
                DispatchQueue.main.async {
                    self.configurationError = error.localizedDescription
                }
                return
            }

            if !self.didAddVideoDataOutput {
                self.videoDataOutput.videoSettings = [
                    kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
                ]
                self.videoDataOutput.alwaysDiscardsLateVideoFrames = true
                self.videoDataOutput.setSampleBufferDelegate(
                    WorkoutAnalysisSampleBufferSink.shared,
                    queue: self.videoDataQueue
                )
                if self.session.canAddOutput(self.videoDataOutput) {
                    self.session.addOutput(self.videoDataOutput)
                    self.didAddVideoDataOutput = true
                }
            }

            self.session.commitConfiguration()
            self.didConfigure = true
            DispatchQueue.main.async { self.configurationError = nil }

            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
}

struct LiveCameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    final class PreviewHost: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }

        var previewLayer: AVCaptureVideoPreviewLayer {
            guard let previewLayer = layer as? AVCaptureVideoPreviewLayer else {
                fatalError("Expected AVCaptureVideoPreviewLayer")
            }
            return previewLayer
        }
    }

    func makeUIView(context: Context) -> PreviewHost {
        let view = PreviewHost()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        Self.applyPreviewOrientation(view.previewLayer.connection, session: session)
        return view
    }

    func updateUIView(_ uiView: PreviewHost, context: Context) {
        if uiView.previewLayer.session !== session {
            uiView.previewLayer.session = session
        }
        Self.applyPreviewOrientation(uiView.previewLayer.connection, session: session)
    }

    static func applyPreviewOrientation(_ connection: AVCaptureConnection?, session: AVCaptureSession) {
        guard let connection else { return }
        let angle = interfaceVideoRotationAngle()
        guard connection.isVideoRotationAngleSupported(angle) else { return }
        if connection.videoRotationAngle != angle {
            connection.videoRotationAngle = angle
        }
        let isFrontCamera = (session.inputs.first as? AVCaptureDeviceInput).map { $0.device.position == .front } ?? false
        if connection.isVideoMirroringSupported {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = isFrontCamera
        }
    }

    private static func interfaceVideoRotationAngle() -> CGFloat {
        let scene = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
        switch scene?.interfaceOrientation ?? .portrait {
        case .portrait: return 90
        case .portraitUpsideDown: return 270
        case .landscapeLeft: return 180
        case .landscapeRight: return 0
        default: return 90
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthSessionManager.shared)
        .environmentObject(NavigationCoordinator())
        .environmentObject(UserViewModel())
        .environmentObject(CartViewModel())
        .environmentObject(PurchaseViewModel())
        .environmentObject(AIBadgeViewModel())
        .environmentObject(WorkoutHistoryStore())
}
