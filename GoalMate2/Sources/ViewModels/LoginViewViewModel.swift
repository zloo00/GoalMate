//
//  LoginViewViewModel.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//
import FirebaseAuth
import Foundation

class LoginViewViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    
    init() {}
    
    func login() {
        guard validate() else {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = "Invalid email or password"
                // You can be more specific with different error cases if you want
                // For example:
                /*
                if let errCode = AuthErrorCode.Code(rawValue: error._code) {
                    switch errCode {
                    case .wrongPassword:
                        self.errorMessage = "Wrong password"
                    case .userNotFound:
                        self.errorMessage = "User not found"
                    default:
                        self.errorMessage = "Login error: \(error.localizedDescription)"
                    }
                }
                */
            }
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
