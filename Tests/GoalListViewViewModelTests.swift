
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
    func testToggleIsDone() {
        let goal = GoalListItem(
            id: "done-id",
            title: "Toggle Test",
            dueDate: Date().addingTimeInterval(3600).timeIntervalSince1970,
            createdDate: Date().timeIntervalSince1970,
            isDone: false,
            note: nil,
            priority: .medium,
            subGoals: nil,
            tags: nil,
            repeatRule: .none,
            repeatEndDate: nil
        )

        viewModel.goals.append(goal)
        viewModel.toggleIsDone(item: goal)

        XCTAssertTrue(viewModel.goals.first(where: { $0.id == goal.id })?.isDone ?? false)
    }
    func testAddSubGoal() {
        let parent = GoalListItem(
            id: "parent-id",
            title: "Parent",
            dueDate: Date().addingTimeInterval(3600).timeIntervalSince1970,
            createdDate: Date().timeIntervalSince1970,
            isDone: false,
            note: nil,
            priority: .low,
            subGoals: [],
            tags: nil,
            repeatRule: .none,
            repeatEndDate: nil
        )

        viewModel.goals.append(parent)
        viewModel.addSubGoal(to: parent, title: "Subtask 1")

        let updated = viewModel.goals.first(where: { $0.id == "parent-id" })
        XCTAssertEqual(updated?.subGoals?.count, 1)
        XCTAssertEqual(updated?.subGoals?.first?.title, "Subtask 1")
    }
    func testUpdateSubGoalTitle() {
        let subGoal = GoalListItem.SubGoal(id: "sub-id", title: "Old Title", isDone: false)
        let parent = GoalListItem(
            id: "parent-update-id",
            title: "Parent",
            dueDate: Date().addingTimeInterval(3600).timeIntervalSince1970,
            createdDate: Date().timeIntervalSince1970,
            isDone: false,
            note: nil,
            priority: .high,
            subGoals: [subGoal],
            tags: nil,
            repeatRule: .none,
            repeatEndDate: nil
        )

        viewModel.goals.append(parent)
        viewModel.updateSubGoalTitle(parent: parent, subGoalID: "sub-id", newTitle: "New Title")

        let updated = viewModel.goals.first(where: { $0.id == "parent-update-id" })
        XCTAssertEqual(updated?.subGoals?.first?.title, "New Title")
    }

}
