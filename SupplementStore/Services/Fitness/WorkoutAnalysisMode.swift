//
//  WorkoutAnalysisMode.swift
//  SupplementStore
//

import Foundation

/// Gate for video-frame analyze calls so other uses of `LiveCameraSession` do not spam the API.
enum WorkoutAnalysisMode {
    private static let lock = NSLock()
    private static var _isActive = false

    static var isActive: Bool {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _isActive
        }
        set {
            lock.lock()
            _isActive = newValue
            lock.unlock()
        }
    }
}
