//
//  GoalListItem.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//

import Foundation

struct GoalListItem: Codable, Identifiable {
    let id: String
    let title: String
    let dueDate: TimeInterval
    let createdDate: TimeInterval
    var isDone: Bool
    mutating func setDone(_ state: Bool) {
        isDone = state
    }
    
}
