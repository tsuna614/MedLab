//
//  LoginViewModel.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 26/3/25.
//

import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var number: String = ""
    @Published var userType: String = ""
    
    private let appViewModel: AppViewModel
    private let authService: AuthServicing
    
    init(appViewModel: AppViewModel, authService: AuthServicing) {
        self.appViewModel = appViewModel
        self.authService = authService
    }
    
    func login(completion: @escaping (Bool) -> Void) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both fields."
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        Task {
            do {
                let response: LoginResponse = try await authService.login(email: email, password: password)
                self.appViewModel.setUser(response.userData)
                UserDefaultsService.shared.setUserId(response.userData.id)
                UserDefaultsService.shared.setAccessToken(response.accessToken)
                self.appViewModel.isAuthenticated = true
                self.isLoading = false
                completion(true)
            } catch {
                print("ERROR!!! \(error.localizedDescription)")
                if error.localizedDescription == "The operation couldn’t be completed. (MedLab.ApiClientError error 5.)" {
                    self.errorMessage = "Invalid email or password" // NOTE: implement proper error handling later
                } else {
                    self.errorMessage = error.localizedDescription
                }
                self.isLoading = false
                completion(false)
            }
        }
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
            id: "",
            email: email,
            firstName: firstName,
            lastName: lastName,
            number: number.isEmpty ? nil : number,
            userType: nil,
            usedVouchersCode: [],
            address: nil
        )
        
        Task {
            do {
                let _: User = try await authService.register(user: user, password: password) // use _ because we don't need to use the response
                login(completion: completion)
            } catch {
                self.errorMessage = error.localizedDescription
                completion(false)
            }
        }
        
        isLoading = false
    }
}
