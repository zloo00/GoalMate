//
//  DailyQuoteView.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 29.05.2025.
//


struct DailyQuoteView: View {
    @State private var quote: Quote?

    var body: some View {
        VStack(spacing: 12) {
            if let quote = quote {
                Text("“\(quote.q)”")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text("- \(quote.a)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                ProgressView("Загрузка цитаты...")
            }
        }
        .onAppear {
            QuoteService.shared.fetchRandomQuote { result in
                DispatchQueue.main.async {
                    self.quote = result
                }
            }
        }
    }
}
