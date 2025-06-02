//
//  GoalDetailCardView.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 02.06.2025.
//


import SwiftUI

struct GoalDetailCardView: View {
    var goal: GoalListItem

    var body: some View {
        VStack(spacing: 16) {
            Text(goal.title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top)

            VStack(alignment: .leading, spacing: 10) {
                Text("📅 Due: \(formatted(Date(timeIntervalSince1970: goal.dueDate)))")
                if let endDate = goal.repeatEndDate {
                    Text("🔁 Repeats until: \(formatted(Date(timeIntervalSince1970: endDate)))")
                }
                Text("🏷️ Priority: \(goal.priority.rawValue.capitalized)")
                if let tags = goal.tags, !tags.isEmpty {
                    Text("🔖 Tags: \(tags.joined(separator: ", "))")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
