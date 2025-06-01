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
    @Published var shouldShowButton: Bool = true

    private let quoteKey = "daily_quote"
    private let dateKey = "quote_date"
    private let calendar = Calendar.current

    func loadQuote() {
        state = .loading

        QuoteService.shared.fetchQuote { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let quote = result {
                    if quote.q.isEmpty || quote.a.isEmpty {
                        self.state = .empty
                    } else {
                        self.state = .success(quote)
                        self.storeQuote(quote)
                        self.shouldShowButton = false
                    }
                } else {
                    self.state = .error("Не удалось загрузить цитату. Проверь соединение.")
                }
            }
        }
    }

    func checkStoredQuote() {
        if let data = UserDefaults.standard.data(forKey: quoteKey),
           let savedQuote = try? JSONDecoder().decode(Quote.self, from: data),
           let savedDate = UserDefaults.standard.object(forKey: dateKey) as? Date,
           calendar.isDateInToday(savedDate) {

            state = .success(savedQuote)
            shouldShowButton = false
        } else {
            state = .idle
            shouldShowButton = true
        }
    }

    private func storeQuote(_ quote: Quote) {
        if let data = try? JSONEncoder().encode(quote) {
            UserDefaults.standard.set(data, forKey: quoteKey)
            UserDefaults.standard.set(Date(), forKey: dateKey)
        }
    }
}
