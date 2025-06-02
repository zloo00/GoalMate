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
            // AR View Background
            ARSceneView(goals: filteredGoals) { goal in
                selectedGoal = goal
                showDetailCard = true
            }
            .edgesIgnoringSafeArea(.all)

            // Control Buttons
            VStack {
                HStack {
                    Spacer()
                    VStack(spacing: 16) {
                        // Filter Button
                        Button(action: {
                            withAnimation(.spring()) {
                                showFilters.toggle()
                            }
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 20))
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }

                        // Priority Filters
                        if showFilters {
                            VStack(spacing: 8) {
                                FilterButton(title: "All", isActive: selectedPriority == nil) {
                                    selectedPriority = nil
                                }
                                FilterButton(title: "High", isActive: selectedPriority == "high") {
                                    selectedPriority = "high"
                                }
                                FilterButton(title: "Medium", isActive: selectedPriority == "medium") {
                                    selectedPriority = "medium"
                                }
                                FilterButton(title: "Low", isActive: selectedPriority == "low") {
                                    selectedPriority = "low"
                                }
                            }
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)
                            .transition(.scale.combined(with: .opacity))
                        }

                        // Close Button
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20))
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 20)
                }
                Spacer()
            }

            // Goal Detail Card
            if showDetailCard, let goal = selectedGoal {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.easeOut) {
                            showDetailCard = false
                            selectedGoal = nil
                        }
                    }

                VStack {
                    Spacer()
                    GoalDetailCardView(goal: goal)
                        .frame(width: UIScreen.main.bounds.width * 0.85, height: 220)
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding(.bottom, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .zIndex(1)
            }
        }
    }
}

// Custom Filter Button View
struct FilterButton: View {
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isActive ? .white : .primary)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(isActive ? Color.blue : Color.clear)
                .cornerRadius(12)
        }
    }
}
