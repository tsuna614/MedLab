//
//  SignupView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 25/3/25.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel: SignupViewModel
    
    init() {
        // Temporary placeholder, real init done in body
        _viewModel = StateObject(wrappedValue: SignupViewModel(appViewModel: AppViewModel()))
    }
    
    var body: some View {
        // Replace the placeholder ViewModel with the one using actual environment object
        SignupViewContent(viewModel: SignupViewModel(appViewModel: appViewModel))
    }
}

struct SignupViewContent: View {
    @ObservedObject var viewModel: SignupViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Let's get started!")
                .font(.largeTitle)
                .bold()
            
            CustomTextField(placeholder: "Email", text: $viewModel.email)
            CustomTextField(placeholder: "First Name", text: $viewModel.firstName)
            CustomTextField(placeholder: "Last Name", text: $viewModel.lastName)
            CustomTextField(placeholder: "Phone (Not required)", text: $viewModel.number, isNumber: true)
            CustomTextField(placeholder: "Password", text: $viewModel.password, isSecure: true)
            CustomTextField(placeholder: "Confirm password", text: $viewModel.confirmPassword, isSecure: true)
            
            if let error = viewModel.errorMessage {
                Text(error).foregroundColor(.red)
            }
            
            if viewModel.isLoading {
                ProgressView()
            } else {
                Button("Login") {
                    viewModel.register { success in
                        
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

