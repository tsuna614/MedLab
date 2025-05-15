//
//  LoginView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 25/3/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel: AuthViewModel
    @StateObject private var authService: AuthService

    init() {
        // Temporary placeholder, real init done in body
        let apiClientInstance = ApiClient(baseURLString: "http://localhost:3000")
        let authServiceInstance = AuthService(apiClient: apiClientInstance)
        _authService = StateObject(wrappedValue: authServiceInstance)
        _viewModel = StateObject(wrappedValue: AuthViewModel(
            appViewModel: AppViewModel(userService: UserService(apiClient: apiClientInstance)),
            authService: authServiceInstance
        ))
    }

    var body: some View {
        // Replace the placeholder ViewModel with the one using actual environment object
        LoginViewContent(authViewModel: AuthViewModel(appViewModel: appViewModel, authService: authService))
    }
}

struct LoginViewContent: View {
    @StateObject var authViewModel: AuthViewModel
//    @EnvironmentObject var cartViewModel: CartViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image("Login")
                    .resizable()
                    .scaledToFit()
                
                Text("Login")
                    .font(.largeTitle)
                    .bold()
                
                CustomTextField(placeholder: "Email", text: $authViewModel.email)
                CustomTextField(placeholder: "Password", text: $authViewModel.password, isSecure: true)
                
                if let error = authViewModel.errorMessage {
                    Text(error).foregroundColor(.red)
                }
                
                if authViewModel.isLoading {
                    ProgressView()
                } else {
                    Button("Login") {
                        authViewModel.login { success in
//                            Task {
//                                await cartViewModel.fetchCart()
//                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                NavigationLink("Don't have an account? Sign up", destination: SignupView(authViewModel: authViewModel))
                    .padding(.top, 10)
                
                Spacer()
            }
            .padding()
        }
    }
}
