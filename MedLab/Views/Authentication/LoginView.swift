//
//  LoginView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 25/3/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel: LoginViewModel

    init() {
        // Temporary placeholder, real init done in body
        _viewModel = StateObject(wrappedValue: LoginViewModel(appViewModel: AppViewModel()))
    }

    var body: some View {
        // Replace the placeholder ViewModel with the one using actual environment object
        LoginViewContent(viewModel: LoginViewModel(appViewModel: appViewModel))
    }
}

struct LoginViewContent: View {
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image("Login")
                    .resizable()
                    .scaledToFit()
                
                Text("Login")
                    .font(.largeTitle)
                    .bold()
                
                CustomTextField(placeholder: "Email", text: $viewModel.email)
                CustomTextField(placeholder: "Password", text: $viewModel.password, isSecure: true)
                
                if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(.red)
                }
                
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Button("Login") {
                        viewModel.login { success in
                            
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                NavigationLink("Don't have an account? Sign up", destination: SignupView())
                    .padding(.top, 10)
                
                Spacer()
            }
            .padding()
        }
    }
}
