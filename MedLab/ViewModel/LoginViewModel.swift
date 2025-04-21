//
//  LoginViewModel.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 26/3/25.
//

import Foundation
import SwiftUI

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var appViewModel: AppViewModel
    
    // MARK: - init
    init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
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
                let dictionary = try await AuthService.shared.login(email: email, password: password)
                if let userDict = dictionary["userData"] as? [String: Any] {
                    self.appViewModel.setUserFromJSON(from: userDict)
                    self.appViewModel.isAuthenticated = true
                    self.isLoading = false
                    completion(true)
                }
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                completion(false)
            }
        }
        
//        AuthService.shared.login(email: email, password: password) { result in
//            DispatchQueue.main.async {
//                self.isLoading = false
//                switch result {
//                case .success(let dictionary):
//                    self.appViewModel.setUserFromJSON(from: dictionary)
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
