//
//  LoginView.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//

import SwiftUI

struct LoginView: View {
    
    @StateObject var viewModel = LoginViewViewModel()
    @State private var showingRegisterView = false
    @State private var showPassword = false // New state variable for password visibility
    
    var body: some View {
        NavigationView {
            VStack {
                // Header
                HeaderView(title: "Goal Mate",
                           subtitle: "Get things done",
                           angle: -15,
                           background: .orange)
                
                // Login form
                Form {
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                    }
                    TextField("Email Address", text: $viewModel.email)
                        .textFieldStyle(DefaultTextFieldStyle())
                        .autocapitalization(.none)
                    
                    // Password field with visibility toggle
                    HStack {
                        if showPassword {
                            TextField("Password", text: $viewModel.password)
                        } else {
                            SecureField("Password", text: $viewModel.password)
                        }
                        
                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .textFieldStyle(DefaultTextFieldStyle())
                    
                    TLButton(
                        title: "Log In",
                        background: .green
                    ) {
                        viewModel.login()
                    }
                    .padding()
                }
                .offset(y: -50)
                
                // Create Account
                VStack {
                    Text("New around here?")
                    
                    Button("Create An Account") {
                        showingRegisterView = true
                    }
                }
                .padding(.bottom, 50)
                
                Spacer()
            }
            .ignoresSafeArea(.keyboard)
            .sheet(isPresented: $showingRegisterView) {
                NavigationView {
                    RegisterView()
                        .navigationBarItems(leading: Button("Back") {
                            showingRegisterView = false
                        })
                }
            }
        }
    }
}

struct LoginView_previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
