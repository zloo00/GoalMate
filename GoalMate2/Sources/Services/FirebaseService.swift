//
//  FirebaseService.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 01.06.2025.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

enum DataState {
    case loading
    case loaded
    case empty
    case error(String)
}

class FirebaseService {
    static let shared = FirebaseService()
    private init() {}
    
    // MARK: - Authentication
    
    func registerUser(email: String, password: String, name: String) async throws -> String {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let userID = result.user.uid
        
        let newUser = User(
            id: userID,
            name: name,
            email: email,
            joined: Date().timeIntervalSince1970
        )
        
        try await Firestore.firestore()
            .collection("users")
            .document(userID)
            .setData(newUser.asDictionary())
        
        return userID
    }
    
    func loginUser(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func logout() throws {
        try Auth.auth().signOut()
    }
    
    // MARK: - User Data
    
    func fetchUser(userId: String) async throws -> User {
        let snapshot = try await Firestore.firestore()
            .collection("users")
            .document(userId)
            .getDocument()
        
        guard let data = snapshot.data() else {
            throw NSError(domain: "User not found", code: 0)
        }
        
        return User(
            id: data["id"] as? String ?? "",
            name: data["name"] as? String ?? "",
            email: data["email"] as? String ?? "",
            joined: data["joined"] as? TimeInterval ?? 0
        )
    }
    
    // MARK: - Goals
    
    func fetchGoals(userId: String) async throws -> [GoalListItem] {
        let snapshot = try await Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("goals")
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: GoalListItem.self) }
    }
    
    func setupGoalsListener(userId: String, completion: @escaping ([GoalListItem]) -> Void) -> ListenerRegistration {
        return Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("goals")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                let goals = documents.compactMap { try? $0.data(as: GoalListItem.self) }
                completion(goals)
            }
    }
    
    func saveGoal(userId: String, goal: GoalListItem) async throws {
        try await Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("goals")
            .document(goal.id)
            .setData(goal.asDictionary())
    }
    
    func deleteGoal(userId: String, goalId: String) async throws {
        try await Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("goals")
            .document(goalId)
            .delete()
    }
    
    func updateGoal(userId: String, goal: GoalListItem) async throws {
        try await saveGoal(userId: userId, goal: goal)
    }
    
    func toggleGoalCompletion(userId: String, goal: GoalListItem) async throws {
        var updatedGoal = goal
        updatedGoal.isDone.toggle()
        try await updateGoal(userId: userId, goal: updatedGoal)
    }
    
    // В FirebaseService
    func toggleSubGoalCompletion(userId: String, parentGoal: GoalListItem, subGoal: GoalListItem.SubGoal) async throws -> GoalListItem {
        var updatedGoal = parentGoal
        guard var subGoals = updatedGoal.subGoals else { return parentGoal }
        
        if let index = subGoals.firstIndex(where: { $0.id == subGoal.id }) {
            // Сначала обновляем локально
            subGoals[index].isDone.toggle()
            updatedGoal.subGoals = subGoals
            
            // Затем синхронизируем с Firebase
            do {
                try await Firestore.firestore()
                    .collection("users")
                    .document(userId)
                    .collection("goals")
                    .document(parentGoal.id)
                    .updateData([
                        "subGoals": subGoals.map { $0.asDictionary() }
                    ])
                
                return updatedGoal
            } catch {
                // Если ошибка - возвращаем исходное состояние
                subGoals[index].isDone.toggle()
                throw error
            }
        }
        
        return parentGoal
    }
    
    func updateGoalTitle(userId: String, goalId: String, newTitle: String) async throws {
        try await Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("goals")
            .document(goalId)
            .updateData(["title": newTitle])
    }
    
    func addSubGoal(userId: String, parentGoalId: String, subGoal: GoalListItem.SubGoal) async throws {
        let db = Firestore.firestore()
        let docRef = db.collection("users")
            .document(userId)
            .collection("goals")
            .document(parentGoalId)
        
        try await docRef.updateData([
            "subGoals": FieldValue.arrayUnion([subGoal.asDictionary()])
        ])
    }
    
    func updateSubGoalTitle(userId: String, parentGoalId: String, subGoalId: String, newTitle: String) async throws {
        let db = Firestore.firestore()
        let docRef = db.collection("users")
            .document(userId)
            .collection("goals")
            .document(parentGoalId)
        
        let snapshot = try await docRef.getDocument()
        guard var subGoals = snapshot.data()?["subGoals"] as? [[String: Any]] else {
            throw NSError(domain: "Subgoals not found", code: 0)
        }
        
        if let index = subGoals.firstIndex(where: { ($0["id"] as? String) == subGoalId }) {
            subGoals[index]["title"] = newTitle
            try await docRef.updateData(["subGoals": subGoals])
        }
    }
    
    func deleteSubGoal(userId: String, parentGoalId: String, subGoalId: String) async throws {
        let db = Firestore.firestore()
        let docRef = db.collection("users")
            .document(userId)
            .collection("goals")
            .document(parentGoalId)
        
        let snapshot = try await docRef.getDocument()
        guard var subGoals = snapshot.data()?["subGoals"] as? [[String: Any]] else {
            throw NSError(domain: "Subgoals not found", code: 0)
        }
        
        subGoals.removeAll { ($0["id"] as? String) == subGoalId }
        try await docRef.updateData(["subGoals": subGoals])
    }
}
