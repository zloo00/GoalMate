//
//  RegisterViewViewModel.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//
import FirebaseFirestore
import FirebaseAuth
import Foundation

class RegisterViewViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    
    init() {}
    
    func register() {
        guard validate() else {
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let userID = result?.user.uid else {
                self?.errorMessage = "Registration failed. Please try again."
                return
            }
            self?.insertUserRecord(id: userID)
        }
    }
    
    private func insertUserRecord(id: String) {
        let newUser = User(id: id,
                          name: name,
                          email: email,
                          joined: Date().timeIntervalSince1970)
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(id)
            .setData(newUser.asDictionary())
    }
    
    private func validate() -> Bool {
        // Check all fields are filled
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please fill in all fields"
            return false
        }
        
        // Check valid email format
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid email address"
            return false
        }
        
        // Check password requirements
        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters long"
            return false
        }
        
        // Check for at least one uppercase letter
        let uppercaseLetterRegex = ".*[A-Z]+.*"
        guard NSPredicate(format: "SELF MATCHES %@", uppercaseLetterRegex).evaluate(with: password) else {
            errorMessage = "Password must contain at least one uppercase letter"
            return false
        }
        
        // Check for at least one lowercase letter
        let lowercaseLetterRegex = ".*[a-z]+.*"
        guard NSPredicate(format: "SELF MATCHES %@", lowercaseLetterRegex).evaluate(with: password) else {
            errorMessage = "Password must contain at least one lowercase letter"
            return false
        }
        
        // Check for at least one number
        let numberRegex = ".*[0-9]+.*"
        guard NSPredicate(format: "SELF MATCHES %@", numberRegex).evaluate(with: password) else {
            errorMessage = "Password must contain at least one number"
            return false
        }
        
        return true
    }
}
