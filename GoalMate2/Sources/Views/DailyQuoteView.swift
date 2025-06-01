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
        VStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.orange, Color.red.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)

                VStack(spacing: 10) {
                    Text("🔥 Motivation Boost 🔥")
                        .font(.headline)
                        .foregroundColor(.white)

                    content

                    if viewModel.shouldShowButton {
                        Button(action: {
                            viewModel.loadQuote()
                        }) {
                            Text("💡 Get motivated")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.25))
                                .cornerRadius(10)
                        }
                        .transition(.opacity)
                    }
                }
                .padding(14)
                .frame(maxWidth: 300)
            }
            .frame(height: 150) // 🔽 Здесь можно менять высоту (например, 180, 150)

        }
        .padding(.horizontal)
        .onAppear {
            viewModel.checkStoredQuote()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            EmptyView()

        case .loading:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))

        case .success(let quote):
            VStack(spacing: 6) {
                Text("“\(quote.q)”")
                    .font(.body)
                    .italic()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 6)

                Text("- \(quote.a)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.85))
            }

        case .empty:
            Text("No quote. Try again later.")
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
