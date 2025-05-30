//
//  GoalListViewViewModel.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//

import FirebaseFirestore
import Foundation

class GoalListViewViewModel: ObservableObject {
    @Published var showingNewItemView = false
    @Published var goals: [GoalListItem] = []
    
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
        fetchGoals()
    }
    
    func fetchGoals() {
        let db = Firestore.firestore()
        db.collection("users")
            .document(userId)
            .collection("goals")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self?.goals = documents.compactMap { doc in
                    try? doc.data(as: GoalListItem.self)
                }
            }
    }
    
    func delete(id: String) {
        let db = Firestore.firestore()
        db.collection("users")
            .document(userId)
            .collection("goals")
            .document(id)
            .delete()
    }
    
    func toggleIsDone(item: GoalListItem) {
        guard let index = goals.firstIndex(where: { $0.id == item.id }) else { return }
        
        var updatedItem = item
        updatedItem.isDone.toggle()
        
        goals[index] = updatedItem
        
        let db = Firestore.firestore()
        db.collection("users")
            .document(userId)
            .collection("goals")
            .document(item.id)
            .setData(updatedItem.asDictionary()) { error in
                if let error = error {
                    print("Error updating isDone: \(error.localizedDescription)")
                }
            }
    }
    
    func toggleSubGoalDone(parent: GoalListItem, subGoal: GoalListItem.SubGoal) {
        guard let parentIndex = goals.firstIndex(where: { $0.id == parent.id }),
              var updatedSubGoals = goals[parentIndex].subGoals else { return }
        
        if let subIndex = updatedSubGoals.firstIndex(where: { $0.id == subGoal.id }) {
            updatedSubGoals[subIndex].isDone.toggle()
            
            goals[parentIndex].subGoals = updatedSubGoals
            
            let db = Firestore.firestore()
            db.collection("users")
                .document(userId)
                .collection("goals")
                .document(parent.id)
                .updateData([
                    "subGoals": updatedSubGoals.map { $0.asDictionary() }
                ]) { error in
                    if let error = error {
                        print("Error updating subGoal isDone: \(error.localizedDescription)")
                    }
                }
        }
    }
    
    func updateGoalTitle(item: GoalListItem, newTitle: String) {
        guard let index = goals.firstIndex(where: { $0.id == item.id }) else { return }
        
        var updatedItem = item
        updatedItem.title = newTitle
        
        goals[index] = updatedItem
        
        let db = Firestore.firestore()
        db.collection("users")
            .document(userId)
            .collection("goals")
            .document(item.id)
            .updateData([
                "title": newTitle
            ]) { error in
                if let error = error {
                    print("Error updating goal title: \(error.localizedDescription)")
                }
            }
    }
    
    // Остальные функции остаются без изменений
    func addSubGoal(to parent: GoalListItem, title: String) {
        guard let index = goals.firstIndex(where: { $0.id == parent.id }) else { return }
        
        var updatedItem = parent
        let newSubGoal = GoalListItem.SubGoal(id: UUID().uuidString, title: title, isDone: false)
        updatedItem.subGoals = (updatedItem.subGoals ?? []) + [newSubGoal]
        
        goals[index] = updatedItem
        
        let db = Firestore.firestore()
        db.collection("users")
            .document(userId)
            .collection("goals")
            .document(parent.id)
            .updateData([
                "subGoals": updatedItem.subGoals?.map { $0.asDictionary() } ?? []
            ]) { error in
                if let error = error {
                    print("Failed to add subGoal: \(error.localizedDescription)")
                }
            }
    }
    
    func updateSubGoalTitle(parent: GoalListItem, subGoalID: String, newTitle: String) {
        guard let parentIndex = goals.firstIndex(where: { $0.id == parent.id }),
              var updatedSubGoals = goals[parentIndex].subGoals else { return }
        
        if let index = updatedSubGoals.firstIndex(where: { $0.id == subGoalID }) {
            updatedSubGoals[index].title = newTitle
            
            goals[parentIndex].subGoals = updatedSubGoals
            
            let db = Firestore.firestore()
            db.collection("users")
                .document(userId)
                .collection("goals")
                .document(parent.id)
                .updateData([
                    "subGoals": updatedSubGoals.map { $0.asDictionary() }
                ]) { error in
                    if let error = error {
                        print("Failed to update subGoal title: \(error.localizedDescription)")
                    }
                }
        }
    }
    
    func deleteSubGoal(at offsets: IndexSet, parent: GoalListItem) {
        guard let parentIndex = goals.firstIndex(where: { $0.id == parent.id }),
              var updatedSubGoals = goals[parentIndex].subGoals else { return }
        
        updatedSubGoals.remove(atOffsets: offsets)
        
        goals[parentIndex].subGoals = updatedSubGoals
        
        let db = Firestore.firestore()
        db.collection("users")
            .document(userId)
            .collection("goals")
            .document(parent.id)
            .updateData([
                "subGoals": updatedSubGoals.map { $0.asDictionary() }
            ]) { error in
                if let error = error {
                    print("Failed to delete subGoal: \(error.localizedDescription)")
                }
            }
    }
    
    func updateGoal(_ updatedGoal: GoalListItem) {
        guard let index = goals.firstIndex(where: { $0.id == updatedGoal.id }) else { return }
        goals[index] = updatedGoal
        
        let db = Firestore.firestore()
        db.collection("users")
            .document(userId)
            .collection("goals")
            .document(updatedGoal.id)
            .setData(updatedGoal.asDictionary()) { error in
                if let error = error {
                    print("Error updating goal: \(error.localizedDescription)")
                }
            }
    }
}
