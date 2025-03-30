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
            errorMessage = "Please enter both fields."
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
            number: nil,
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
        
        //        AuthService.shared.register(user: user, password: password) { result in
        //            DispatchQueue.main.async {
        //                self.isLoading = false
        //                switch result {
        //                case .success(let result):
        //                    self.appViewModel.setUserFromJSON(from: result)
        //                    self.appViewModel.isAuthenticated = true
        //                    completion(true)
        //                case .failure(let error):
        //                    self.errorMessage = error.localizedDescription
        //                    completion(false)
        //                }
        //            }
        //        }
    }
}
