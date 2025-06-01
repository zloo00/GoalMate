//
//  RegisterViewViewModel.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//
import Foundation

@MainActor
class RegisterViewViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var state: DataState = .loaded
    
    func register() async {
        guard validate() else { return }

        state = .loading
        
        do {
            _ = try await FirebaseService.shared.registerUser(
                email: email,
                password: password,
                name: name
            )
            state = .loaded
        } catch {
            errorMessage = "Registration failed. Please try again."
            state = .error(errorMessage)
        }
    }
    
    private func validate() -> Bool {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please fill in all fields"
            return false
        }

        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid email address"
            return false
        }

        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters long"
            return false
        }

        let uppercaseLetterRegex = ".*[A-Z]+.*"
        guard NSPredicate(format: "SELF MATCHES %@", uppercaseLetterRegex).evaluate(with: password) else {
            errorMessage = "Password must contain at least one uppercase letter"
            return false
        }

        let lowercaseLetterRegex = ".*[a-z]+.*"
        guard NSPredicate(format: "SELF MATCHES %@", lowercaseLetterRegex).evaluate(with: password) else {
            errorMessage = "Password must contain at least one lowercase letter"
            return false
        }

        let numberRegex = ".*[0-9]+.*"
        guard NSPredicate(format: "SELF MATCHES %@", numberRegex).evaluate(with: password) else {
            errorMessage = "Password must contain at least one number"
            return false
        }

        return true
    }
}
