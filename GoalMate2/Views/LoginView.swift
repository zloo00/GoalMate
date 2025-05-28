//
//  LoginView.swift
//  GoalMate2
//
//  Created by Алуа Жолдыкан on 28.05.2025.
//

import SwiftUI

struct LoginView: View {
    
    @StateObject var viewModel = LoginViewViewModel()
    
    var body: some View {
        NavigationView{
            VStack{
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
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(DefaultTextFieldStyle())
                    
                    TLButton(
                        title: "Log In",
                        background: .green
                    )
                    {
                        viewModel.login()
                    }
                    
                    .padding()
                }
                .offset(y:-50)
                
                // Create Acccount
                VStack {
                    Text("New around here?")
                    
                    // Show Register
                    NavigationLink("Create An Account", destination: RegisterView())
                }
                .padding(.bottom, 50)
                Spacer()
                
            }
        }
        
        
    }
    
    
    
}
struct LoginView_previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
