//
//  NewItemView.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//

import SwiftUI

struct NewItemView: View {
    @StateObject var viewModel = NewItemViewViewModel()
    @Binding var newItemPresented: Bool

    @State private var isSelectingEndDate = false

    var body: some View {
        VStack {
            Text("New Item")
                .font(.system(size: 32))
                .bold()
                .padding(.top, 40)

            Form {
                Section(header: Text("Details")) {
                    TextField("Title", text: $viewModel.title)
                        .textFieldStyle(DefaultTextFieldStyle())

                    TextField("Note (optional)", text: $viewModel.note)
                        .textFieldStyle(DefaultTextFieldStyle())

                    TextField("Tags (comma separated)", text: $viewModel.tags)
                        .textFieldStyle(DefaultTextFieldStyle())

                    Picker("Priority", selection: $viewModel.priority) {
                        ForEach(GoalListItem.Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue.capitalized)
                                .tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Repeat")) {
                    Picker("Repeat Rule", selection: $viewModel.repeatRule) {
                        ForEach(GoalListItem.RepeatRule.allCases) { rule in
                            Text(rule.rawValue.capitalized)
                                .tag(rule)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    if viewModel.repeatRule != .none && viewModel.repeatRule != .custom {
                        Picker("Select", selection: $isSelectingEndDate) {
                            Text("Start").tag(false)
                            Text("End").tag(true)
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        DatePicker(
                            isSelectingEndDate ? "Repeat End Date" : "Due Date",
                            selection: Binding(
                                get: {
                                    isSelectingEndDate ? (viewModel.repeatEndDate ?? viewModel.dueDate) : viewModel.dueDate
                                },
                                set: {
                                    if isSelectingEndDate {
                                        viewModel.repeatEndDate = $0
                                    } else {
                                        viewModel.dueDate = $0
                                    }
                                }
                            ),
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(GraphicalDatePickerStyle())

                        Text(daysLeftText)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                Section {
                    TLButton(title: "Save", background: .green) {
                        if viewModel.canSave {
                            viewModel.save()
                            newItemPresented = false
                        } else {
                            viewModel.showAlert = true
                        }
                    }
                    .padding(.top)
                }
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Invalid input"),
                  message: Text("Please check your inputs and try again."),
                  dismissButton: .default(Text("OK")))
        }
    }

    private var daysLeftText: String {
        let calendar = Calendar.current
        let fromDate = calendar.startOfDay(for: Date())
        let toDate = calendar.startOfDay(for: isSelectingEndDate ? (viewModel.repeatEndDate ?? viewModel.dueDate) : viewModel.dueDate)
        let diff = calendar.dateComponents([.day], from: fromDate, to: toDate).day ?? 0

        if diff > 0 {
            return "\(diff) day(s) left"
        } else if diff < 0 {
            return "\(abs(diff)) day(s) ago"
        } else {
            return "Today is the day!"
        }
    }
}

struct NewItemView_Previews: PreviewProvider {
    static var previews: some View {
        NewItemView(newItemPresented: .constant(true))
    }
}
