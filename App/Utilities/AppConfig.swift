// App/AppConfig.swift
import Foundation

enum AppEnvironment: String {
    case development = "Development"
    case production = "Production"
}

struct AppConfig {
    static let environment: AppEnvironment = {
        if let envString = Bundle.main.object(forInfoDictionaryKey: "AppEnvironment") as? String,
           let env = AppEnvironment(rawValue: envString) {
            return env
        }
        return .development
    }()

    static var isProduction: Bool { environment == .production }
}
