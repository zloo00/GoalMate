//
//  DailyQuoteView.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 29.05.2025.
//

import SwiftUI

struct DailyQuoteView: View {
    @StateObject private var viewModel = QuoteViewModel()

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.orange, Color.red.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)

            VStack(spacing: 12) {
                Text("🔥 Motivation Boost 🔥")
                    .font(.headline)
                    .foregroundColor(.white)

                content

                Button(action: {
                    viewModel.loadQuote()
                }) {
                    Text("🔄 Обновить цитату")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.top, 4)
                }

                Text("💪🌟 Keep going!")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .onAppear {
            viewModel.loadQuote()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))

        case .success(let quote):
            VStack(spacing: 6) {
                Text("“\(quote.q)”")
                    .font(.body)
                    .italic()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text("- \(quote.a)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.85))
            }

        case .empty:
            Text("Цитата пуста. Попробуй ещё раз.")
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()

        case .error(let message):
            Text(message)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}
