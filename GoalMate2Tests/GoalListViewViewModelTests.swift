//
//  GoalListViewViewModelTests.swift
//  GoalMate2Tests
//
//  Created by Алуа Жолдыкан on 29.05.2025.
//

import XCTest
@testable import GoalMate2

final class GoalListViewViewModelTests: XCTestCase {
    var viewModel: GoalListViewViewModel!

    override func setUp() {
        super.setUp()
        viewModel = MockGoalListViewViewModel(userId: "testUser123")
    }

    func testAddGoal() {
        let initialCount = viewModel.goals.count
        let goal = GoalListItem(
            id: UUID().uuidString,
            title: "Test Goal",
            dueDate: Date().addingTimeInterval(3600).timeIntervalSince1970,
            createdDate: Date().timeIntervalSince1970,
            isDone: false,
            note: "Test note",
            priority: .medium,
            subGoals: [],
            tags: ["test"],
            repeatRule: .none,
            repeatEndDate: nil
        )

        viewModel.goals.append(goal)

        XCTAssertEqual(viewModel.goals.count, initialCount + 1)
        XCTAssertEqual(viewModel.goals.last?.title, "Test Goal")
    }

    func testDeleteGoal() {
        let id = UUID().uuidString
        let goal = GoalListItem(
            id: id,
            title: "To Delete",
            dueDate: Date().addingTimeInterval(3600).timeIntervalSince1970,
            createdDate: Date().timeIntervalSince1970,
            isDone: false,
            note: nil,
            priority: .low,
            subGoals: nil,
            tags: nil,
            repeatRule: .none,
            repeatEndDate: nil
        )

        viewModel.goals.append(goal)
        viewModel.delete(id: id)

        XCTAssertFalse(viewModel.goals.contains { $0.id == id })
    }
}
