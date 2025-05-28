//
//  GoalMate2App.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 27.05.2025.
//

import SwiftUI
import FirebaseCore

@main
struct GoalMate2App: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
