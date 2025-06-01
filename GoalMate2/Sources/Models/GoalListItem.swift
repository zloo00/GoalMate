//
//  GoalListItem.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//

import Foundation

struct GoalListItem: Identifiable, Codable {
    var id: String
    var title: String
    var dueDate: TimeInterval
    var createdDate: TimeInterval
    var isDone: Bool
    var note: String?
    var priority: Priority
    var subGoals: [SubGoal]?
    var tags: [String]?
    var repeatRule: RepeatRule
    var repeatEndDate: TimeInterval?
    
    mutating func setDone(_ done: Bool) {
        self.isDone = done
    }
    
    enum Priority: String, CaseIterable, Codable {
        case low, medium, high
    }
    
    enum RepeatRule: String, CaseIterable, Identifiable, Codable {
        case none
        case daily
        case weekly
        case monthly
        case custom
        
        var id: String { self.rawValue }
    }
    
    struct SubGoal: Identifiable, Codable {
        var id: String
        var title: String
        var isDone: Bool
    }
}
