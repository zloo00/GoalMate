//
//  GoalListItemsView.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
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
    
    init(userId: String) {
        self.userId = userId
        self._viewModel = StateObject(wrappedValue: GoalListViewViewModel(userId: userId))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                DailyQuoteView()

                List {
                    ForEach(viewModel.goals.indices, id: \.self) { index in
                        NavigationLink(destination: GoalDetailView(viewModel: viewModel, goal: $viewModel.goals[index])) {
                            GoalListItemView(item: viewModel.goals[index], viewModel: viewModel)
                        }
                        .swipeActions {
                            Button("Delete") {
                                itemToDelete = viewModel.goals[index].id
                            }.tint(.red)
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
