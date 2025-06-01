
//
//  GoalListViewViewModelTests.swift
//  GoalMate2Tests
//
//  Created by Алуа Жолдыкан on 29.05.2025.
//

import XCTest
@testable import GoalMate2

@MainActor
final class GoalListViewViewModelTests: XCTestCase {
    var viewModel: MockGoalListViewViewModel!

    override func setUp() {
        super.setUp()
        viewModel = MockGoalListViewViewModel(userId: "testUser123")
        viewModel.goals = []
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
            subGoals: [],
            tags: [],
            repeatRule: .none,
            repeatEndDate: nil
        )

        viewModel.goals.append(goal)
        XCTAssertTrue(viewModel.goals.contains(where: { $0.id == id }))
        
        viewModel.delete(id: id)
        
        XCTAssertFalse(viewModel.goals.contains(where: { $0.id == id }))
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
            subGoals: [],
            tags: [],
            repeatRule: .none,
            repeatEndDate: nil
        )
        viewModel.goals.append(goal)
        
        XCTAssertFalse(viewModel.goals.first(where: { $0.id == goal.id })?.isDone ?? true)
        
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
            tags: [],
            repeatRule: .none,
            repeatEndDate: nil
        )

        viewModel.goals.append(parent)
        
        XCTAssertEqual(viewModel.goals.first(where: { $0.id == parent.id })?.subGoals?.count, 0)
        
        var updatedParent = parent
        let newSubGoal = GoalListItem.SubGoal(id: UUID().uuidString, title: "Subtask 1", isDone: false)
        updatedParent.subGoals?.append(newSubGoal)
        
        if let index = viewModel.goals.firstIndex(where: { $0.id == parent.id }) {
            viewModel.goals[index] = updatedParent
        }

        XCTAssertEqual(viewModel.goals.first(where: { $0.id == parent.id })?.subGoals?.count, 1)
        XCTAssertEqual(viewModel.goals.first(where: { $0.id == parent.id })?.subGoals?.first?.title, "Subtask 1")
    }

    func testUpdateSubGoalTitle() {
        let subGoal = GoalListItem.SubGoal(id: "sub-id", title: "Old Title", isDone: false)
        var parent = GoalListItem(
            id: "parent-update-id",
            title: "Parent",
            dueDate: Date().addingTimeInterval(3600).timeIntervalSince1970,
            createdDate: Date().timeIntervalSince1970,
            isDone: false,
            note: nil,
            priority: .high,
            subGoals: [subGoal],
            tags: [],
            repeatRule: .none,
            repeatEndDate: nil
        )

        viewModel.goals.append(parent)
        
        if let parentIndex = viewModel.goals.firstIndex(where: { $0.id == parent.id }),
           var subGoals = viewModel.goals[parentIndex].subGoals,
           let subGoalIndex = subGoals.firstIndex(where: { $0.id == "sub-id" }) {
            subGoals[subGoalIndex].title = "New Title"
            parent.subGoals = subGoals
            viewModel.goals[parentIndex] = parent
        }
        
        XCTAssertEqual(viewModel.goals.first(where: { $0.id == parent.id })?.subGoals?.first?.title, "New Title")
    }
}
