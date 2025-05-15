//
//  SignupView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 25/3/25.
//

import SwiftUI

//struct SignupView: View {
//    @EnvironmentObject var appViewModel: AppViewModel
//    @StateObject private var viewModel: AuthViewModel
//    @StateObject private var authService: AuthService
//
//    init() {
//        // Temporary placeholder, real init done in body
//        let apiClientInstance = ApiClient(baseURLString: "http://localhost:3000")
//        let authServiceInstance = AuthService(apiClient: apiClientInstance)
//        _authService = StateObject(wrappedValue: authServiceInstance)
//        _viewModel = StateObject(wrappedValue: AuthViewModel(appViewModel: AppViewModel(), authService: authServiceInstance))
//    }
//    
//    var body: some View {
//        // Replace the placeholder ViewModel with the one using actual environment object
//        SignupViewContent(viewModel: AuthViewModel(appViewModel: appViewModel, authService: authService))
//    }
//}

struct SignupView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Let's get started!")
                .font(.largeTitle)
                .bold()
            
            CustomTextField(placeholder: "Email", text: $authViewModel.email)
            CustomTextField(placeholder: "First Name", text: $authViewModel.firstName)
            CustomTextField(placeholder: "Last Name", text: $authViewModel.lastName)
            CustomTextField(placeholder: "Phone (Not required)", text: $authViewModel.number, isNumber: true)
            CustomTextField(placeholder: "Password", text: $authViewModel.password, isSecure: true)
            CustomTextField(placeholder: "Confirm password", text: $authViewModel.confirmPassword, isSecure: true)
            
            if let error = authViewModel.errorMessage {
                Text(error).foregroundColor(.red)
            }
            
            if authViewModel.isLoading {
                ProgressView()
            } else {
                Button("Login") {
                    authViewModel.register { success in
                        
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            
            Button("Already have an account? Sign in")
            {
                dismiss()
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .padding()
    }
}

