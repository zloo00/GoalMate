//
//  GoalListItemViewViewModel.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//
import FirebaseAuth
import FirebaseFirestore
import Foundation
class GoalListItemViewViewModel: ObservableObject{
    init(){
        
    }
    func toogleIsDone(item: GoalListItem){
        var itemCopy = item
        itemCopy.setDone(!item.isDone)
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let db = Firestore.firestore()
        db.collection("users")
            .document(uid)
            .collection("goals")
            .document(itemCopy.id)
            .setData(itemCopy.asDictionary())
    }
}
