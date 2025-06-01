//
//  ProfileViewViewModel.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//
import FirebaseAuth
import Foundation

@MainActor
class ProfileViewViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage = ""
    @Published var state: DataState = .loaded
    
    func fetchUser() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "No authenticated user"
            state = .error(errorMessage)
            return
        }

        state = .loading

        do {
            user = try await FirebaseService.shared.fetchUser(userId: userId)
            state = user == nil ? .empty : .loaded
        } catch {
            errorMessage = "Failed to fetch user data"
            state = .error(errorMessage)
        }
    }
    
    func logOut() {
        do {
            try FirebaseService.shared.logout()
            user = nil
            state = .loaded
        } catch {
            errorMessage = "Logout failed"
            state = .error(errorMessage)
        }
    }
}
