//
//  QuoteService.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 29.05.2025.
//

import Foundation

class QuoteService {
    static let shared = QuoteService()
    private let baseUrl = "https://zenquotes.io/api/random"
    
    func fetchQuote(completion: @escaping (Quote?) -> Void) {
        // Изменено на let, так как components не изменяется
        let components = URLComponents(string: baseUrl)!
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Улучшенная обработка ошибок
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            do {
                let quotes = try JSONDecoder().decode([Quote].self, from: data)
                DispatchQueue.main.async { completion(quotes.first) }
            } catch {
                print("Decoding error: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }
        
        task.resume()
    }
}
