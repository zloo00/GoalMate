//
//  GoalListItemsView.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//
import FirebaseFirestore
import SwiftUI

struct GoalListView: View {
    @StateObject var viewModel: GoalListViewViewModel
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
        self._viewModel = StateObject(wrappedValue: GoalListViewViewModel(userId: userId))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.goals.indices, id: \.self) { index in
                        NavigationLink(destination: GoalDetailView(viewModel: viewModel, goal: $viewModel.goals[index])) {
                            GoalListItemView(item: viewModel.goals[index], viewModel: viewModel)
                        }
                        .swipeActions {
                            Button("Delete") {
                                viewModel.delete(id: viewModel.goals[index].id)
                            }.tint(.red)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Goal List")
            .toolbar {
                Button {
                    viewModel.showingNewItemView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $viewModel.showingNewItemView) {
                NewItemView(newItemPresented: $viewModel.showingNewItemView)
            }
        }
    }
}
