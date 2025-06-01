//
//  QuoteViewModel.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 29.05.2025.
//


import Foundation

enum QuoteFetchState {
    case idle
    case loading
    case success(Quote)
    case empty
    case error(String)
}

class QuoteViewModel: ObservableObject {
    @Published var state: QuoteFetchState = .idle

    func loadQuote() {
        state = .loading
        QuoteService.shared.fetchQuote { [weak self] result in
            DispatchQueue.main.async {
                if let quote = result {
                    if quote.q.isEmpty || quote.a.isEmpty {
                        self?.state = .empty
                    } else {
                        self?.state = .success(quote)
                    }
                } else {
                    self?.state = .error("Не удалось загрузить цитату. Проверь соединение.")
                }
            }
        }
    }
}
