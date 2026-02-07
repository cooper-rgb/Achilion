import Foundation
import FirebaseCore

final class FirebaseManager {
    static let shared = FirebaseManager()

    private(set) var isConfigured = false

    private init() {}

    /// Safely configures Firebase if it hasn't been configured already.
    func configureIfNeeded() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            isConfigured = true
            #if DEBUG
            print("[FirebaseManager] Firebase configured")
            #endif
        } else {
            isConfigured = true
            #if DEBUG
            print("[FirebaseManager] Firebase already configured")
            #endif
        }
    }
}

// Backwards-compatible typealiases to catch common misspellings found in some codebases
// (non-breaking and safe; these simply alias to the correct type name).
