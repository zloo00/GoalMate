//
//  Extentions.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//

import Foundation
    
extension Encodable{
    func asDictionary() -> [String: Any]{
        guard let data = try? JSONEncoder().encode(self) else {
            return [:]
        }
        do {
            let json = try JSONSerialization.jsonObject(with:data) as? [String: Any]
            return json ?? [:]
        } catch{
            return [:]
        }
    }
}
extension GoalListItem {
    func asDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "title": title,
            "dueDate": dueDate,
            "createdDate": createdDate,
            "isDone": isDone,
            "priority": priority.rawValue,
            "tags": tags,
            "repeatRule": repeatRule.rawValue
        ]

        if let note = note {
            dict["note"] = note
        }

        if let subGoals = subGoals {
            dict["subGoals"] = subGoals.map { $0.asDictionary() }
        }

        if let repeatEndDate = repeatEndDate {
            dict["repeatEndDate"] = repeatEndDate
        }

        return dict
    }

    func timeRemainingText() -> String {
        let calendar = Calendar.current
        let now = Date()
        let dueDateDate = Date(timeIntervalSince1970: dueDate)
        let toDate = calendar.startOfDay(for: dueDateDate)
        let fromDate = calendar.startOfDay(for: now)
        let diff = calendar.dateComponents([.day], from: fromDate, to: toDate).day ?? 0

        if diff > 0 {
            return "\(diff) day(s) left"
        } else if diff < 0 {
            return "\(abs(diff)) day(s) ago"
        } else {
            return "Due today!"
        }
    }

    func detailedTimeRemainingText() -> String {
        let dueDateDate = Date(timeIntervalSince1970: dueDate)
        let interval = dueDateDate.timeIntervalSince(Date())
        let absInterval = abs(interval)

        let hours = Int(absInterval) / 3600
        let minutes = (Int(absInterval) % 3600) / 60

        if interval > 0 {
            return "\(hours)h \(minutes)m left"
        } else {
            return "\(hours)h \(minutes)m ago"
        }
    }

    func dateRangeText() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        let startDate = Date(timeIntervalSince1970: createdDate)
        let endDate = Date(timeIntervalSince1970: repeatEndDate ?? dueDate)

        let start = formatter.string(from: startDate)
        let end = formatter.string(from: endDate)

        return "From \(start)\nTo \(end)"
    }
}

extension GoalListItem.SubGoal {
    func asDictionary() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "isDone": isDone
        ]
    }
}
