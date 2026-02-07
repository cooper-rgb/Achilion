//
//  AchilionApp.swift
//  Achilion
//
//  Created by Cooper Ceva on 2/3/26.
//

import SwiftUI
import SwiftData
import FirebaseCore
import Foundation

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    // Use FirebaseManager to ensure Firebase is configured exactly once and to centralize setup.
    FirebaseManager.shared.configureIfNeeded()

    return true
  }
}



@main
struct AchilionApp: App {
    // Attach the existing AppDelegate so its lifecycle methods run (Firebase is configured there)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
