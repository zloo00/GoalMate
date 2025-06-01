//
//  ContentView.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 27.05.2025.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewViewModel()
    var body: some View {
        
        if viewModel.isSignedIn, !viewModel.currentUserId.isEmpty {
            // Signed In
            accountView
            
        }else {
            LoginView()
        }

    }
    @ViewBuilder
    var accountView: some View {
        TabView {
            GoalListView(userId: viewModel.currentUserId)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
