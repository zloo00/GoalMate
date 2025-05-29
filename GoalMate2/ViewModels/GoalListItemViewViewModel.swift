//
//  GoalListItemViewViewModel.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//
import FirebaseAuth
import FirebaseFirestore
import Foundation

class GoalListItemViewViewModel: ObservableObject {
    @Published var subGoals: [GoalListItem.SubGoal] = []

    private let db = Firestore.firestore()
    
    init() {}
    
    func toggleIsDone(item: GoalListItem) {
        var itemCopy = item
        itemCopy.setDone(!item.isDone)
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ No user logged in.")
            return
        }
        
        db.collection("users")
            .document(uid)
            .collection("goals")
            .document(itemCopy.id)
            .setData(itemCopy.asDictionary()) { error in
                if let error = error {
                    print("❌ Failed to update goal: \(error.localizedDescription)")
                } else {
                    print("✅ Goal '\(itemCopy.title)' updated successfully.")
                }
            }
    }
    
    func toggleSubGoalDone(parent: GoalListItem, subGoal: GoalListItem.SubGoal) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ No user logged in.")
            return
        }

        guard var subGoals = parent.subGoals else {
            print("⚠️ No subGoals found.")
            return
        }

        guard let index = subGoals.firstIndex(where: { $0.id == subGoal.id }) else {
            print("⚠️ SubGoal with id \(subGoal.id) not found in parent goal.")
            return
        }

        subGoals[index].isDone.toggle()
        var updatedParent = parent
        updatedParent.subGoals = subGoals

        db.collection("users")
            .document(uid)
            .collection("goals")
            .document(parent.id)
            .setData(updatedParent.asDictionary()) { error in
                if let error = error {
                    print("❌ Failed to update subGoal: \(error.localizedDescription)")
                } else {
                    print("✅ SubGoal '\(subGoal.title)' updated in goal '\(parent.title)'.")
                }
            }
    }
}
