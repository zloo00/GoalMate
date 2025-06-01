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
    
    func toggleIsDone(item: GoalListItem) async {
        await parentViewModel.toggleIsDone(item: item)
    }
    
    func toggleSubGoalDone(parent: GoalListItem, subGoal: GoalListItem.SubGoal) async {
        await parentViewModel.toggleSubGoalDone(parent: parent, subGoal: subGoal)
    }
    
    func editGoalTitle(item: GoalListItem, newTitle: String) async {
        await parentViewModel.updateGoalTitle(item: item, newTitle: newTitle)
    }
}
