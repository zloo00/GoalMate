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
    @State private var showDeleteConfirmation = false
    @State private var indexSetToDelete: IndexSet?
    @State private var timeRemaining: String = ""
    @State private var timer: Timer?
    @State private var progress: Double = 0.0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Section
                VStack(alignment: .leading, spacing: 12) {
                    // Editable Goal Title
                    TextField("Goal Title", text: $editedTitle)
                        .font(.system(size: 28, weight: .bold))
                        .padding(.vertical, 8)
                        .onSubmit {
                            goal.title = editedTitle
                            viewModel.updateGoal(goal)
                        }
                    
                    // Time Remaining Counter
                    VStack(alignment: .leading, spacing: 6) {
                        Text("TIME REMAINING")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(timeRemaining)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(timeRemainingColor())
                            .onAppear {
                                startTimer()
                                updateProgress()
                            }
                            .onDisappear {
                                timer?.invalidate()
                            }
                    }
                    .padding(.vertical, 8)
                    
                    // Progress Bar
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("PROGRESS")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(progress * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        ProgressView(value: progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: progressColor()))
                            .frame(height: 6)
                            .cornerRadius(3)
                            .animation(.easeInOut, value: progress)
                    }
                }
                .padding(.bottom, 8)
                
                // Dates Section
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("START DATE")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(Date(timeIntervalSince1970: goal.dueDate).formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: 4) {
                            Text("DEADLINE")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(Date(timeIntervalSince1970: goal.repeatEndDate ?? goal.dueDate).formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .foregroundColor(isOverdue(goal) ? .red : .primary)
                        }
                    }
                    
                    // Editable Deadline
                    DatePicker("Change Deadline", selection: $editedDeadline, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .onChange(of: editedDeadline) { _, newValue in
                            if newValue < Date().startOfDay {
                                showAlert = true
                                editedDeadline = Date().startOfDay
                            } else {
                                goal.repeatEndDate = newValue.timeIntervalSince1970
                                viewModel.updateGoal(goal)
                                updateTimeRemaining()
                            }
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text("Invalid Deadline"),
                                message: Text("Please choose a date that is today or in the future."),
                                dismissButton: .default(Text("OK")))
                        }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Priority & Repeat Rule
                HStack {
                    HStack {
                        Image(systemName: "flag.fill")
                            .foregroundColor(priorityColor())
                        Text("\(goal.priority.rawValue.capitalized) Priority")
                            .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    if goal.repeatRule != .none {
                        HStack {
                            Image(systemName: "repeat")
                            Text("Repeats: \(goal.repeatRule.rawValue.capitalized)")
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Toggle for goals without subgoals
                if goal.subGoals?.isEmpty ?? true {
                    Toggle(isOn: Binding(
                        get: { goal.isDone },
                        set: {
                            goal.isDone = $0
                            viewModel.updateGoal(goal)
                            updateProgress()
                        })
                    ) {
                        Text("Mark as Completed")
                            .font(.headline)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                
                // Subgoals Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("SUBGOALS")
                            .font(.headline)
                        Spacer()
                        Text("\(completedSubgoalsCount())/\(goal.subGoals?.count ?? 0)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if let subGoals = goal.subGoals, !subGoals.isEmpty {
                        ForEach(subGoals) { sub in
                            HStack {
                                Button {
                                    withAnimation {
                                        viewModel.toggleSubGoalDone(parent: goal, subGoal: sub)
                                        updateProgress()
                                    }
                                } label: {
                                    Image(systemName: sub.isDone ? "checkmark.circle.fill" : "circle")
                                        .font(.title2)
                                        .foregroundColor(sub.isDone ? .green : Color(.systemGray4))
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Text(sub.title)
                                    .strikethrough(sub.isDone, color: .gray)
                                    .foregroundColor(sub.isDone ? .gray : .primary)
                                
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            .contextMenu {
                                Button(role: .destructive) {
                                    if let index = subGoals.firstIndex(where: { $0.id == sub.id }) {
                                        viewModel.deleteSubGoal(at: IndexSet(integer: index), parent: goal)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    } else {
                        Text("No subgoals yet. Add below.")
                            .foregroundColor(.secondary)
                            .italic()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 20)
                    }
                    
                    // Add Subgoal
                    HStack {
                        TextField("New subgoal", text: $newSubGoalTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .submitLabel(.done)
                            .onSubmit {
                                addSubGoal()
                            }
                        
                        Button(action: addSubGoal) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .disabled(newSubGoalTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(.top, 8)
                }
                .padding(.top, 8)
                
                Spacer()
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle("Goal Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            self.editedTitle = goal.title
            self.editedDeadline = Date(timeIntervalSince1970: goal.repeatEndDate ?? goal.dueDate)
            updateTimeRemaining()
            updateProgress()
        }
        .onChange(of: goal.title) { oldValue, newValue in
            editedTitle = newValue
        }
        .onChange(of: goal.repeatEndDate) { oldValue, newValue in
            if let newDueDate = newValue {
                editedDeadline = Date(timeIntervalSince1970: newDueDate)
                updateTimeRemaining()
            }
        }
        .onDisappear {
            timer?.invalidate()
            if editedTitle != goal.title {
                goal.title = editedTitle
            }
            let newTimestamp = editedDeadline.timeIntervalSince1970
            if newTimestamp != goal.repeatEndDate {
                goal.repeatEndDate = newTimestamp
            }
            viewModel.updateGoal(goal)
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Subgoal"),
                message: Text("Are you sure you want to delete this subgoal?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let indexSet = indexSetToDelete {
                        viewModel.deleteSubGoal(at: indexSet, parent: goal)
                        updateProgress()
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // MARK: - Timer Functions
    
    private func startTimer() {
        timer?.invalidate()
        updateTimeRemaining()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            updateTimeRemaining()
        }
    }
    
    private func updateTimeRemaining() {
        let deadlineDate = Date(timeIntervalSince1970: goal.repeatEndDate ?? goal.dueDate)
        let now = Date()
        
        guard deadlineDate > now else {
            timeRemaining = "Deadline passed"
            return
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute, .second],
                                               from: now,
                                               to: deadlineDate)
        
        if let days = components.day, let hours = components.hour,
           let minutes = components.minute, let seconds = components.second {
            
            if days > 0 {
                timeRemaining = String(format: "%d days %02d:%02d:%02d", days, hours, minutes, seconds)
            } else {
                timeRemaining = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            }
        }
    }
    
    private func timeRemainingColor() -> Color {
        let deadlineDate = Date(timeIntervalSince1970: goal.repeatEndDate ?? goal.dueDate)
        let now = Date()
        let timeLeft = deadlineDate.timeIntervalSince(now)
        
        if timeLeft < 86400 { // Less than 24 hours
            return .red
        } else if timeLeft < 259200 { // Less than 3 days
            return .orange
        } else {
            return .blue
        }
    }
    
    // MARK: - Progress Functions
    
    private func updateProgress() {
        guard let subs = goal.subGoals, !subs.isEmpty else {
            progress = goal.isDone ? 1.0 : 0.0
            return
        }
        let doneCount = subs.filter { $0.isDone }.count
        progress = Double(doneCount) / Double(subs.count)
    }
    
    private func progressColor() -> Color {
        if progress == 1.0 {
            return .green
        } else if progress > 0.7 {
            return Color(red: 0.2, green: 0.8, blue: 0.2)
        } else if progress > 0.3 {
            return .blue
        } else {
            return .orange
        }
    }
    
    private func priorityColor() -> Color {
        switch goal.priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
    
    private func completedSubgoalsCount() -> Int {
        return goal.subGoals?.filter { $0.isDone }.count ?? 0
    }
    
    // MARK: - Helper Functions
    
    private func addSubGoal() {
        let trimmed = newSubGoalTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        viewModel.addSubGoal(to: goal, title: trimmed)
        newSubGoalTitle = ""
        updateProgress()
    }
    
    private func isOverdue(_ goal: GoalListItem) -> Bool {
        !goal.isDone && Date(timeIntervalSince1970: goal.repeatEndDate ?? goal.dueDate) < Date()
    }
}

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
