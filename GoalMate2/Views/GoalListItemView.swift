//
//  GoalListViewItem.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//

import SwiftUI
struct GoalListItemView: View {
    var item: GoalListItem
    @ObservedObject var viewModel: GoalListViewViewModel
    @State private var isExpanded = false

    init(item: GoalListItem, viewModel: GoalListViewViewModel) {
        self.item = item
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(isOverdue(item) ? .red : .primary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(priorityText(item.priority))
                    .font(.caption)
                    .padding(6)
                    .background(priorityColor(priority: item.priority).opacity(0.2))
                    .foregroundColor(priorityColor(priority: item.priority))
                    .cornerRadius(6)

                Spacer()

                Text(Date(timeIntervalSince1970: item.dueDate).formatted(date: .abbreviated, time: .shortened))
                    .font(.footnote)
                    .foregroundColor(isOverdue(item) ? .red : .secondary)
            }

            HStack(spacing: 20) {
                // MARK DONE button
                Button {
                    withAnimation {
                        viewModel.toggleIsDone(item: item)
                    }
                } label: {
                    VStack {
                        Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(item.isDone ? .green : .blue)
                            .imageScale(.large)
                        Text("Mark Done")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
                .buttonStyle(PlainButtonStyle())

                // SHOW DETAILS button
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    VStack {
                        Image(systemName: isExpanded ? "chevron.down.circle.fill" : "chevron.right.circle")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                        Text("Show Details")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.vertical, 6)

            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(daysUntilDeadline(for: item)) day(s) until deadline")
                                .font(.caption2)
                                .foregroundColor(isOverdue(item) ? .red : .blue)

                            if item.repeatRule != .none {
                                Text("Repeat: \(item.repeatRule.rawValue.capitalized)")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                                    .padding(4)
                                    .background(Color.blue.opacity(0.15))
                                    .cornerRadius(4)
                            }

                            if let note = item.note, !note.isEmpty {
                                Text(note)
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            HStack {
                                Text("Priority: \(item.priority.rawValue.capitalized)")
                                    .font(.caption)
                                    .padding(4)
                                    .background(priorityColor(priority: item.priority).opacity(0.2))
                                    .foregroundColor(priorityColor(priority: item.priority))
                                    .cornerRadius(4)

                                if let tags = item.tags, !tags.isEmpty {
                                    Text("Tags: \(tags.joined(separator: ", "))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                            }

                            if let subGoals = item.subGoals, !subGoals.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Subgoals:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    ForEach(subGoals) { sub in
                                        HStack(spacing: 12) {
                                            Button {
                                                withAnimation {
                                                    viewModel.toggleSubGoalDone(parent: item, subGoal: sub)
                                                }
                                            } label: {
                                                Image(systemName: sub.isDone ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(sub.isDone ? .green : .blue)
                                                    .imageScale(.medium)
                                            }
                                            .buttonStyle(PlainButtonStyle())

                                            Text(sub.title)
                                                .font(.body)
                                                .foregroundColor(sub.isDone ? .gray : (isOverdue(sub) ? .red : .primary))
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
                .padding(.top, 8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - Helpers

    private func priorityText(_ priority: GoalListItem.Priority) -> String {
        switch priority {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }

    private func priorityColor(priority: GoalListItem.Priority) -> Color {
        switch priority {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }

    private func isOverdue(_ goal: GoalListItem) -> Bool {
        !goal.isDone && Date(timeIntervalSince1970: goal.dueDate) < Date()
    }

    private func isOverdue(_ sub: GoalListItem.SubGoal) -> Bool {
        !sub.isDone
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
