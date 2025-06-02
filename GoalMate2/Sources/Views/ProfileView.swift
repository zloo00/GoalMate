//
//  ProfileView.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if let user = viewModel.user {
                        profile(user: user)
                    } else {
                        ProgressView("Loading Profile...")
                            .padding(.top, 50)
                    }
                }
                .padding(.top, 20)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        }
        .onAppear {
            Task {
                await viewModel.fetchUser()
            }
        }
    }
    
    @ViewBuilder
    func profile(user: User) -> some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing))
                    .frame(width: 150, height: 150)
                    .shadow(color: Color.blue.opacity(0.2), radius: 10, x: 0, y: 5)
                
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                    .frame(width: 140, height: 140)
                    .background(
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.red]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing))
                    )
            }
            .padding(.vertical, 20)
            
            VStack(alignment: .leading, spacing: 16) {
                infoRow(label: "Name", value: user.name)
                Divider()
                infoRow(label: "Email", value: user.email)
                Divider()
                infoRow(label: "Member Since",
                       value: "\(Date(timeIntervalSince1970: user.joined).formatted(date: .abbreviated, time: .shortened))")
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
            
            Button(action: {
                viewModel.logOut()
            }) {
                HStack {
                    Spacer()
                    Text("Log Out")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.red)
                .cornerRadius(10)
                .shadow(color: Color.red.opacity(0.3), radius: 5, x: 0, y: 2)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func infoRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label + ":")
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
