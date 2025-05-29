//
//  GoalListItemRowView.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//

import SwiftUI

struct GoalListItemRowView: View {
    var item: GoalListItem

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(isOverdue(item) ? .red : .primary)
                    .lineLimit(1)

                Text(daysRemainingText(for: item))
                    .font(.caption)
                    .foregroundColor(isOverdue(item) ? .red : .secondary)
            }

            Spacer()

            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(width: 100)

            Text("\(Int(progress * 100))%")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .trailing)
        }
        .padding(.vertical, 8)
    }

    private var progress: Double {
        guard let subs = item.subGoals, !subs.isEmpty else {
            return item.isDone ? 1.0 : 0.0
        }
        let doneCount = subs.filter { $0.isDone }.count
        return Double(doneCount) / Double(subs.count)
    }

    private func daysRemainingText(for goal: GoalListItem) -> String {
        let days = daysUntilDeadline(for: goal)
        if days == 0 && isOverdue(goal) {
            return "Overdue"
        } else if days == 0 {
            return "Today"
        } else {
            return "\(days) day(s) left"
        }
    }

    private func isOverdue(_ goal: GoalListItem) -> Bool {
        !goal.isDone && Date(timeIntervalSince1970: goal.dueDate) < Date()
    }

    private func daysUntilDeadline(for goal: GoalListItem) -> Int {
        let now = Date()
        let dueDate = Date(timeIntervalSince1970: goal.dueDate)
        let calendar = Calendar.current

        if dueDate < now {
            return 0
        }

        let startOfNow = calendar.startOfDay(for: now)
        let startOfDue = calendar.startOfDay(for: dueDate)

        let daysDiff = calendar.dateComponents([.day], from: startOfNow, to: startOfDue).day ?? 0
        return max(daysDiff, 0)
    }
}
