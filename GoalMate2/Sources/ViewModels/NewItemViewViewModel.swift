//
//  NewItemViewViewModel.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//
import FirebaseAuth
import Foundation

@MainActor
class NewItemViewViewModel: ObservableObject {
    @Published var title = ""
    @Published var dueDate = Date()
    @Published var note = ""
    @Published var priority: GoalListItem.Priority = .medium
    @Published var tags: String = ""
    @Published var showAlert = false
    @Published var repeatRule: GoalListItem.RepeatRule = .none
    @Published var repeatEndDate: Date? = nil
    @Published var errorMessage = ""
    @Published var state: DataState = .loaded

    init() {}

    var canSave: Bool {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        guard dueDate >= Date().addingTimeInterval(-86400) else {
            return false
        }
        if repeatRule != .none, let repeatEnd = repeatEndDate {
            if repeatEnd < dueDate {
                return false
            }
        }
        return true
    }

    func save() async {
        guard canSave else {
            showAlert = true
            return
        }

        guard let uID = Auth.auth().currentUser?.uid else {
            errorMessage = "User not logged in"
            state = .error(errorMessage)
            return
        }

        state = .loading
        do {
            let newId = UUID().uuidString
            let tagList = tags
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

            let newItem = GoalListItem(
                id: newId,
                title: title,
                dueDate: dueDate.timeIntervalSince1970,
                createdDate: Date().timeIntervalSince1970,
                isDone: false,
                note: note.isEmpty ? nil : note,
                priority: priority,
                subGoals: nil,
                tags: tagList,
                repeatRule: repeatRule,
                repeatEndDate: repeatEndDate?.timeIntervalSince1970
            )

            try await FirebaseService.shared.saveGoal(userId: uID, goal: newItem)
            state = .loaded
        } catch {
            errorMessage = "Failed to save goal"
            state = .error(errorMessage)
        }
    }
}
