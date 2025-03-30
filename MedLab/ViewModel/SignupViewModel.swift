//
//  SignupViewModel.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 27/3/25.
//

import Foundation
import SwiftUI

@MainActor
class SignupViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var number: String = ""
    @Published var userType: String = ""
    
    private var appViewModel: AppViewModel
    
    init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
    }
    
    func register(completion: @escaping (Bool) -> Void) {
        guard !email.isEmpty,
              !password.isEmpty,
              !confirmPassword.isEmpty,
              !firstName.isEmpty,
              !lastName.isEmpty
        else {
            errorMessage = "Please enter every required field."
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Your passwords do not match"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let user = User(
            email: email,
            firstName: firstName,
            lastName: lastName,
            number: number.isEmpty ? nil : number,
            userType: nil,
            receiptsId: nil
        )
        
        Task {
            do {
                let result = try await AuthService.shared.register(user: user, password: password)
                self.appViewModel.setUserFromJSON(from: result)
                self.appViewModel.isAuthenticated = true
                completion(true)
            } catch {
                self.errorMessage = error.localizedDescription
                completion(false)
            }
        }
        
        isLoading = false
    }
}
