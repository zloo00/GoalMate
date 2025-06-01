//
//  GoalListItemsView.swift
//  GoalMate2
//
//  Updated with stylish sorting dropdown
//

import FirebaseFirestore
import SwiftUI
import RealityKit
import ARKit

struct GoalListView: View {
    @StateObject var viewModel: GoalListViewViewModel
    private let userId: String
    
    @State private var showingARView = false
    @State private var itemToDelete: String? = nil
    @State private var selectedSortOption: SortOption = .priority
    @State private var showSortOptions = false
    
    enum SortOption: String, CaseIterable {
        case priority = "Priority"
        case alphabetical = "A-Z"
        case deadline = "Date"
        
        var icon: String {
            switch self {
            case .priority: return "flag.fill"
            case .alphabetical: return "textformat.abc"
            case .deadline: return "calendar"
            }
        }
    }
    
    init(userId: String) {
        self.userId = userId
        self._viewModel = StateObject(wrappedValue: GoalListViewViewModel(userId: userId))
    }
    
    private var sortedGoals: [GoalListItem] {
        switch selectedSortOption {
        case .priority:
            return viewModel.goals.sorted {
                let priorityOrder: [GoalListItem.Priority] = [.high, .medium, .low]
                let priorityIndex0 = priorityOrder.firstIndex(of: $0.priority) ?? 0
                let priorityIndex1 = priorityOrder.firstIndex(of: $1.priority) ?? 0
                
                if priorityIndex0 != priorityIndex1 {
                    return priorityIndex0 < priorityIndex1
                }
                return $0.title < $1.title
            }
        case .alphabetical:
            return viewModel.goals.sorted { $0.title < $1.title }
        case .deadline:
            return viewModel.goals.sorted {
                let date1 = $0.repeatEndDate ?? $0.dueDate
                let date2 = $1.repeatEndDate ?? $1.dueDate
                return date1 < date2
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                DailyQuoteView()
                
                // Sorting dropdown button
                HStack {
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button(action: {
                                selectedSortOption = option
                            }) {
                                HStack {
                                    Image(systemName: option.icon)
                                        .frame(width: 20)
                                    Text(option.rawValue)
                                    Spacer()
                                    if selectedSortOption == option {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: selectedSortOption.icon)
                                .font(.system(size: 14, weight: .medium))
                            Text(selectedSortOption.rawValue)
                                .font(.system(size: 14, weight: .medium))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                List {
                    ForEach(sortedGoals.indices, id: \.self) { index in
                        NavigationLink(destination: GoalDetailView(viewModel: viewModel, goal: $viewModel.goals[index])) {
                            GoalListItemView(item: sortedGoals[index], viewModel: viewModel)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                itemToDelete = sortedGoals[index].id
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(Color.blue)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .alert("Confirm Deletion", isPresented: Binding<Bool>(
                get: { itemToDelete != nil },
                set: { _ in itemToDelete = nil }
            )) {
                Button("Delete", role: .destructive) {
                    if let id = itemToDelete {
                        viewModel.delete(id: id)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this goal?")
            }
            .navigationTitle("Goal List")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.showingNewItemView = true
                    } label: {
                        Image(systemName: "plus")
                    }

                    Button {
                        showingARView = true
                    } label: {
                        Image(systemName: "arkit")
                    }
                    .sheet(isPresented: $showingARView) {
                        ARViewScreen()
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingNewItemView) {
                NewItemView(newItemPresented: $viewModel.showingNewItemView)
            }
        }
    }
}

// MARK: - Preview
struct GoalListView_Previews: PreviewProvider {
    static var previews: some View {
        GoalListView(userId: "exampleUserId")
    }
}
