//
//  DailyQuoteView.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 29.05.2025.
//

import SwiftUI

struct DailyQuoteView: View {
    @State private var quote: Quote?

    var body: some View {
        ZStack {
            // Градиент на фоне
            LinearGradient(
                gradient: Gradient(colors: [Color.orange, Color.red.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)

            VStack(spacing: 10) {
                Text("🔥 Motivation Boost 🔥")
                    .font(.headline)
                    .foregroundColor(.white)

                if let quote = quote {
                    Text("“\(quote.q)”")
                        .font(.body)
                        .italic()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Text("- \(quote.a)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.top, 4)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .onAppear {
                            QuoteService.shared.fetchQuote { result in
                                DispatchQueue.main.async {
                                    self.quote = result
                                }
                            }
                        }
                }

                Text("💪🌟 Keep going!")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }
}
