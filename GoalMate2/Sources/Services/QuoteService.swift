//
//  QuoteService.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 29.05.2025.
//

import Foundation

class QuoteService {
    static let shared = QuoteService()
    private let url = URL(string: "https://zenquotes.io/api/random")!

    func fetchQuote(completion: @escaping (Quote?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            do {
                let quotes = try JSONDecoder().decode([Quote].self, from: data)
                completion(quotes.first)
            } catch {
                print("Quote decoding error: \(error)")
                completion(nil)
            }
        }

        task.resume()
    }
}

