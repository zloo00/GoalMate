//
//  QuoteServiceTests.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 29.05.2025.
//


import XCTest
@testable import GoalMate2

final class QuoteServiceTests: XCTestCase {
    func testFetchQuote() {
        let expectation = XCTestExpectation(description: "Quote fetched")

        QuoteService.shared.fetchQuote { quote in
            XCTAssertNotNil(quote)
            XCTAssertFalse(quote?.q.isEmpty ?? true)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }
}
