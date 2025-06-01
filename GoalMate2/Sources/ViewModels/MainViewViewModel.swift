//
//  MainViewViewModel.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//

import FirebaseAuth
import Foundation

@MainActor
class MainViewViewModel: ObservableObject {
    @Published var currentUserId: String = ""
    @Published var state: DataState = .loaded

    private var handler: AuthStateDidChangeListenerHandle?

    init() {
        self.handler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUserId = user?.uid ?? ""
            }
        }
    }

    var isSignedIn: Bool {
        Auth.auth().currentUser != nil
    }

    deinit {
        if let handler = handler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
}
