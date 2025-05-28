//
//  Extentions.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//

import Foundation
    
extension Encodable{
    func asDictionary() -> [String: Any]{
        guard let data = try? JSONEncoder().encode(self) else {
            return [:]
        }
        do {
            let json = try JSONSerialization.jsonObject(with:data) as? [String: Any]
            return json ?? [:]
        } catch{
            return [:]
        }
    }
}
