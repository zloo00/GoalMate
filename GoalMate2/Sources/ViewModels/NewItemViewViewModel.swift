//
//  NewItemViewViewModel.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//
import FirebaseAuth
import FirebaseFirestore
import Foundation

class NewItemViewViewModel: ObservableObject {
    
    @Published var title = ""
    @Published var dueDate = Date()
    @Published var note = ""
    @Published var priority: GoalListItem.Priority = .medium
    @Published var tags: String = "" // пользователи вводят через запятую
    @Published var showAlert = false
    @Published var repeatRule: GoalListItem.RepeatRule = .none
    @Published var repeatEndDate: Date? = nil

    init() {}
    
    var canSave: Bool {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        guard dueDate >= Date().addingTimeInterval(-86400) else {
            return false
        }
        // При необходимости добавить проверку repeatEndDate >= dueDate
        if repeatRule != .none, let repeatEnd = repeatEndDate {
            if repeatEnd < dueDate {
                return false
            }
        }
        return true
    }
    
    func save() {
        guard canSave else {
            showAlert = true
            return
        }

        guard let uID = Auth.auth().currentUser?.uid else {
            return
        }

        let newId = UUID().uuidString
        let tagList = tags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let newItem = GoalListItem(
            id: newId,
            title: title,
            dueDate: dueDate.timeIntervalSince1970,
            createdDate: Date().timeIntervalSince1970,
            isDone: false,
            note: note.isEmpty ? nil : note,
            priority: priority,
            subGoals: nil,           // обязательно до tags
            tags: tagList,           // после subGoals
            repeatRule: repeatRule,
            repeatEndDate: repeatEndDate?.timeIntervalSince1970
        )

        
        let db = Firestore.firestore()
        db.collection("users")
            .document(uID)
            .collection("goals")
            .document(newId)
            .setData(newItem.asDictionary())
    }
}
