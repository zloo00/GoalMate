//
//  ARViewScreen.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 29.05.2025.
//
import SwiftUI

struct ARViewScreen: View {
    @ObservedObject var viewModel: GoalListViewViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedGoal: GoalListItem? = nil
    @State private var showDetailCard = false
    @State private var showFilters = false
    @State private var selectedPriority: String? = nil

    var filteredGoals: [GoalListItem] {
        guard let priority = selectedPriority else {
            return viewModel.goals
        }
        return viewModel.goals.filter { $0.priority.rawValue == priority }
    }

    var body: some View {
        ZStack {
            ARSceneView(goals: filteredGoals) { goal in
                selectedGoal = goal
                showDetailCard = true
            }
            .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Button(action: {
                            showFilters.toggle()
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }

                        if showFilters {
                            VStack(spacing: 6) {
                                Button("All") { selectedPriority = nil }
                                Button("High") { selectedPriority = "high" }
                                Button("Medium") { selectedPriority = "medium" }
                                Button("Low") { selectedPriority = "low" }
                            }
                            .font(.caption)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                        }

                        Button("Close") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showDetailCard) {
            if let goal = selectedGoal {
                GoalDetailCardView(goal: goal)
            }
        }
    }
}
