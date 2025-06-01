//
//  GoalListViewViewModel.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//
import FirebaseFirestore
import Foundation
import Combine

@MainActor
class GoalListViewViewModel: ObservableObject {
    @Published var showingNewItemView = false
    @Published var goals: [GoalListItem] = []
    @Published var errorMessage = ""
    @Published var state: DataState = .loaded
    
    private let userId: String
    private var listener: ListenerRegistration?
    
    init(userId: String) {
        self.userId = userId
        setupGoalsListener()
    }
    
    deinit {
        listener?.remove()
    }
    
    private func setupGoalsListener() {
        state = .loading
        listener = FirebaseService.shared.setupGoalsListener(userId: userId) { [weak self] goals in
            Task { @MainActor in
                self?.goals = goals
                self?.state = goals.isEmpty ? .empty : .loaded
            }
        }
    }
    
    func delete(id: String) {
        Task {
            errorMessage = ""
            state = .loading
            do {
                try await FirebaseService.shared.deleteGoal(userId: userId, goalId: id)
                state = .loaded
            } catch {
                errorMessage = "Failed to delete goal"
                state = .error(errorMessage)
            }
        }
    }
    
    func toggleIsDone(item: GoalListItem) {
        Task {
            errorMessage = ""
            state = .loading
            do {
                try await FirebaseService.shared.toggleGoalCompletion(userId: userId, goal: item)
                state = .loaded
            } catch {
                errorMessage = "Failed to update goal"
                state = .error(errorMessage)
            }
        }
    }
    
    func toggleSubGoalDone(parent: GoalListItem, subGoal: GoalListItem.SubGoal) {
        Task {
            errorMessage = ""
            state = .loading
            do {
                _ = try await FirebaseService.shared.toggleSubGoalCompletion(
                    userId: userId,
                    parentGoal: parent,
                    subGoal: subGoal
                )
                state = .loaded
            } catch {
                errorMessage = "Failed to update subgoal"
                state = .error(errorMessage)
            }
        }
    }
    
    func updateGoalTitle(item: GoalListItem, newTitle: String) {
        Task {
            errorMessage = ""
            state = .loading
            do {
                try await FirebaseService.shared.updateGoalTitle(
                    userId: userId,
                    goalId: item.id,
                    newTitle: newTitle
                )
                state = .loaded
            } catch {
                errorMessage = "Failed to update title"
                state = .error(errorMessage)
            }
        }
    }
    
    func addSubGoal(to parent: GoalListItem, title: String) {
        Task {
            errorMessage = ""
            state = .loading
            do {
                let newSubGoal = GoalListItem.SubGoal(
                    id: UUID().uuidString,
                    title: title,
                    isDone: false
                )
                try await FirebaseService.shared.addSubGoal(
                    userId: userId,
                    parentGoalId: parent.id,
                    subGoal: newSubGoal
                )
                state = .loaded
            } catch {
                errorMessage = "Failed to add subgoal"
                state = .error(errorMessage)
            }
        }
    }
    
    func updateSubGoalTitle(parent: GoalListItem, subGoalID: String, newTitle: String) {
        Task {
            errorMessage = ""
            state = .loading
            do {
                try await FirebaseService.shared.updateSubGoalTitle(
                    userId: userId,
                    parentGoalId: parent.id,
                    subGoalId: subGoalID,
                    newTitle: newTitle
                )
                state = .loaded
            } catch {
                errorMessage = "Failed to update subgoal title"
                state = .error(errorMessage)
            }
        }
    }
    
    func deleteSubGoal(at offsets: IndexSet, parent: GoalListItem) {
        guard let subGoals = parent.subGoals else { return }
        let idsToDelete = offsets.map { subGoals[$0].id }
        
        Task {
            errorMessage = ""
            state = .loading
            do {
                for id in idsToDelete {
                    try await FirebaseService.shared.deleteSubGoal(
                        userId: userId,
                        parentGoalId: parent.id,
                        subGoalId: id
                    )
                }
                state = .loaded
            } catch {
                errorMessage = "Failed to delete subgoal"
                state = .error(errorMessage)
            }
        }
    }
    
    func updateGoal(_ updatedGoal: GoalListItem) {
        Task {
            errorMessage = ""
            state = .loading
            do {
                try await FirebaseService.shared.updateGoal(userId: userId, goal: updatedGoal)
                state = .loaded
            } catch {
                errorMessage = "Failed to update goal"
                state = .error(errorMessage)
            }
        }
    }
}
