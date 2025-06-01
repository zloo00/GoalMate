//
//  GoalListItemViewViewModel.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//
import Foundation

@MainActor
class GoalListItemViewViewModel: ObservableObject {
    private let parentViewModel: GoalListViewViewModel
    
    init(parentViewModel: GoalListViewViewModel) {
        self.parentViewModel = parentViewModel
    }
    
    func toggleIsDone(item: GoalListItem) {
        parentViewModel.toggleIsDone(item: item)
    }
    
    func toggleSubGoalDone(parent: GoalListItem, subGoal: GoalListItem.SubGoal) {
        parentViewModel.toggleSubGoalDone(parent: parent, subGoal: subGoal)
    }
    
    func editGoalTitle(item: GoalListItem, newTitle: String) {
        parentViewModel.updateGoalTitle(item: item, newTitle: newTitle)
    }
}
