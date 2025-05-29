import XCTest
@testable import GoalMate2

final class GoalListViewViewModelTests: XCTestCase {
    var viewModel: GoalListViewViewModel!

    override func setUp() {
        super.setUp()
        viewModel = GoalListViewViewModel(userId: "testUser123")
    }

    func testAddGoal() {
        let initialCount = viewModel.goals.count
        let goal = GoalModel(id: "1", title: "Test", tasks: [], isCompleted: false)

        viewModel.goals.append(goal)

        XCTAssertEqual(viewModel.goals.count, initialCount + 1)
        XCTAssertEqual(viewModel.goals.last?.title, "Test")
    }

    func testDeleteGoal() {
        let goal = GoalModel(id: "123", title: "Delete me", tasks: [], isCompleted: false)
        viewModel.goals.append(goal)

        viewModel.delete(id: "123")

        XCTAssertFalse(viewModel.goals.contains { $0.id == "123" })
    }
}
