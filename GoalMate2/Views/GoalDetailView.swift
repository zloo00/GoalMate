//
//  GoalDetailView.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//

import SwiftUI

struct GoalDetailView: View {
    @ObservedObject var viewModel: GoalListViewViewModel
    @Binding var goal: GoalListItem
    @State private var newSubGoalTitle = ""

    @State private var editedTitle: String = ""
    @State private var editedDeadline: Date = Date()
    @State private var showAlert = false



    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Editable Goal Title
            TextField("Goal Title", text: $editedTitle)
                .font(.largeTitle)
                .bold()
                .onSubmit {
                    goal.title = editedTitle
                    viewModel.updateGoal(goal)
                }

            // Editable Deadline
            DatePicker("Deadline", selection: $editedDeadline, displayedComponents: .date)
                .onChange(of: editedDeadline) { newValue in
                    if newValue < Date().startOfDay {
                        showAlert = true
                        editedDeadline = Date().startOfDay
                    } else {
                        goal.dueDate = newValue.timeIntervalSince1970
                        viewModel.updateGoal(goal)
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Invalid Deadline"),
                        message: Text("Please choose a date that is today or in the future."),
                        dismissButton: .default(Text("OK"))
                    )
                }

            // Original deadline display (optional — можно удалить, если не нужен)
            Text("Deadline: \(Date(timeIntervalSince1970: goal.dueDate).formatted(date: .abbreviated, time: .omitted))")
                .font(.subheadline)
                .foregroundColor(isOverdue(goal) ? .red : .secondary)

            // Progress bar
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: progress == 1.0 ? .green : .blue))
                .frame(height: 8)
                .cornerRadius(4)
                .animation(.easeInOut, value: progress)

            Text("Progress: \(Int(progress * 100))%")
                .font(.caption)
                .foregroundColor(.secondary)

            Divider()

            // NEW: Priority и RepeatRule (если нужны)
            HStack {
                Text("Priority: \(goal.priority.rawValue.capitalized)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                if goal.repeatRule != .none {
                    Text("Repeats: \(goal.repeatRule.rawValue.capitalized)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            // NEW: Если нет подцелей, показать переключатель "Отметить как выполненное"
            if goal.subGoals?.isEmpty ?? true {
                Toggle(isOn: Binding(
                    get: { goal.isDone },
                    set: {
                        goal.isDone = $0
                        viewModel.updateGoal(goal)
                    })
                ) {
                    Text("Mark as Done")
                        .font(.headline)
                }
            }

            Text("Subgoals")
                .font(.headline)

            if let subGoals = goal.subGoals, !subGoals.isEmpty {
                List {
                    ForEach(subGoals) { sub in
                        HStack {
                            Button {
                                withAnimation {
                                    viewModel.toggleSubGoalDone(parent: goal, subGoal: sub)
                                }
                            } label: {
                                Image(systemName: sub.isDone ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(sub.isDone ? .green : .blue)
                            }
                            .buttonStyle(PlainButtonStyle())

                            Text(sub.title)
                                .strikethrough(sub.isDone, color: .gray)
                                .foregroundColor(sub.isDone ? .gray : .primary)

                            Spacer()
                        }
                    }
                    .onDelete { indexSet in
                        viewModel.deleteSubGoal(at: indexSet, parent: goal)
                    }
                }
                .listStyle(PlainListStyle())
                .frame(maxHeight: 300)
            } else {
                Text("No subgoals yet. Add below.")
                    .foregroundColor(.secondary)
                    .italic()
            }

            HStack {
                TextField("New subgoal title", text: $newSubGoalTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .submitLabel(.done)  // добавлено: кнопка Done на клавиатуре
                    .onSubmit {
                        addSubGoal()
                    }

                Button(action: addSubGoal) {
                    Label("Add", systemImage: "plus.circle.fill")
                        .labelStyle(IconOnlyLabelStyle())
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .disabled(newSubGoalTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Goal Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            self.editedTitle = goal.title
            self.editedDeadline = Date(timeIntervalSince1970: goal.dueDate)
        }
        // NEW: обновлять локальные редактируемые поля при изменении goal
        .onChange(of: goal.title) { newTitle in
            editedTitle = newTitle
        }

        .onChange(of: goal.dueDate) { newDueDate in
            editedDeadline = Date(timeIntervalSince1970: newDueDate)
        }

        // NEW: автосохранение при выходе с экрана
        .onDisappear {
            if editedTitle != goal.title {
                goal.title = editedTitle
            }
            let newTimestamp = editedDeadline.timeIntervalSince1970
            if newTimestamp != goal.dueDate {
                goal.dueDate = newTimestamp
            }
            viewModel.updateGoal(goal)
        }
    }

    private var progress: Double {
        guard let subs = goal.subGoals, !subs.isEmpty else {
            return goal.isDone ? 1.0 : 0.0
        }
        let doneCount = subs.filter { $0.isDone }.count
        return Double(doneCount) / Double(subs.count)
    }

    private func addSubGoal() {
        let trimmed = newSubGoalTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        viewModel.addSubGoal(to: goal, title: trimmed)
        newSubGoalTitle = ""
    }

    private func isOverdue(_ goal: GoalListItem) -> Bool {
        !goal.isDone && Date(timeIntervalSince1970: goal.dueDate) < Date()
    }
}

// 🔄 Вспомогательное расширение:
extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
