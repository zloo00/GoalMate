//
//  GoalListItemsView.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//
import FirebaseFirestore
import SwiftUI

struct GoalListView: View {
    @StateObject var viewModel : GoalListViewViewModel
    @FirestoreQuery var items: [GoalListItem]
    private let userId: String
    init(userId: String) {
        self.userId = userId
        // users/<id>/goals/<entries>
        self._items = FirestoreQuery(
            collectionPath: "users/\(userId)/goals"
        )
        self._viewModel = StateObject(
            wrappedValue:
                GoalListViewViewModel(userId: userId))
    }
    var body: some View {
        NavigationView{
            VStack{
                List(items){
                    item in
                    GoalListItemView(item: item)
                        .swipeActions {
                            Button("Delete"){
                                // Delete
                                viewModel.delete(id: item.id)
                            }
                            .tint(.red)
                            
                        }
                }
                .listStyle(PlainListStyle())
                
            }
            .navigationTitle(Text("Goal List"))
            .toolbar {
                Button{
                    // Action
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
struct GoalListView_Previews: PreviewProvider {
    static var previews: some View {
        GoalListView(userId: "HXIUMzz99DTWgHnhXZloHk7tbuH2")
    }
}

// HXIUMzz99DTWgHnhXZloHk7tbuH2
