//
//  ARViewScreen.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 29.05.2025.
//
import SwiftUI

struct ARViewScreen: View {
    @ObservedObject var viewModel: GoalListViewViewModel

    var body: some View {
        ZStack {
            ARSceneView(goals: viewModel.goals)
                .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    Spacer()
                    Button("Close") {
                        // Можно закрыть или использовать dismiss
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding()
                }
                Spacer()
            }
        }
    }
}
