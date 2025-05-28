//
//  GoalListViewItem.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//

import SwiftUI

struct GoalListItemView: View {
    @StateObject var viewModel = GoalListItemViewViewModel()
    let item: GoalListItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.body)
                Text(Date(timeIntervalSince1970: item.dueDate).formatted(date: .abbreviated,
                    time: .shortened))
                .font(.footnote)
                .foregroundColor(Color(.secondaryLabel))
            }
            
            Spacer()
            
            Button {
                viewModel.toogleIsDone(item: item)
                
            } label: {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(Color.blue)
            }
        }
    }
}

struct ToDolistItemView_Previews: PreviewProvider {
    static var previews: some View {
        GoalListItemView(item: .init(
            id: "123",
            title: "Get milk",
            dueDate: Date().timeIntervalSince1970,
            createdDate: Date().timeIntervalSince1970,
            isDone: true))
    }
}
