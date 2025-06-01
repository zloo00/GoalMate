//
//  LoginViewViewModel.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//

import FirebaseAuth
import Foundation

@MainActor
class LoginViewViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var state: DataState = .loaded
    
    func login() async {
        guard validate() else { return }
        
        state = .loading
        do {
            try await FirebaseService.shared.loginUser(email: email, password: password)
            state = .loaded
        } catch {
            handleLoginError(error)
            state = .error(errorMessage)
        }
    }
    
    private func handleLoginError(_ error: Error) {
        if let authError = error as NSError?,
           let code = AuthErrorCode(rawValue: authError.code) {
            switch code {
            case .wrongPassword:
                errorMessage = "Wrong password"
            case .userNotFound:
                errorMessage = "User not found"
            case .userDisabled:
                errorMessage = "Account disabled"
            case .invalidEmail:
                errorMessage = "Invalid email format"
            default:
                errorMessage = "Login error: \(error.localizedDescription)"
            }
        } else {
            errorMessage = "Login failed. Please try again."
        }
    }

    
    private func validate() -> Bool {
        errorMessage = ""
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please fill in all fields"
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid email."
            return false
        }
        
        return true
    }
}
