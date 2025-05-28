//
//  User.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//

import Foundation
struct User: Codable {
    let id: String
    let name: String
    let email: String
    let joined: TimeInterval
}
