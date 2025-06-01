//
//  MockGoalListViewViewModel.swift
//  GoalMate2Tests
//
//  Created by Алуа Жолдыкан on 29.05.2025.
//

import Foundation
@testable import GoalMate2

final class MockGoalListViewViewModel: GoalListViewViewModel {
    
    override init(userId: String) {
        super.init(userId: userId)
        self.goals = []
    }

    func fetchGoals() {
        // ничего не делаем
    }
    
    override func delete(id: String) {
        if let index = goals.firstIndex(where: { $0.id == id }) {
            goals.remove(at: index)
        }
    }

    override func toggleIsDone(item: GoalListItem) {
        if let index = goals.firstIndex(where: { $0.id == item.id }) {
            goals[index].isDone.toggle()
        }
    }
}
