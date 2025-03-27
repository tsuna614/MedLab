//
//  AppViewModel.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 26/3/25.
//

import SwiftUI

class AppViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = true
    @Published var user: User?
    
    init() {
        checkStoredCredentials()
    }
    
    func checkStoredCredentials() {
        guard
            let userId = UserDefaultsService.shared.getUserId(),
            let token = UserDefaultsService.shared.getAccessToken()
        else {
            // Not logged in
            print("Credentials not found")
            isAuthenticated = false
            isLoading = false
            return
        }
        
        // Try to fetch user (token might be expired)
        UserService.shared.fetchUser(userId: userId, accessToken: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.isAuthenticated = true
                case .failure:
                    self.isAuthenticated = false
                }
                self.isLoading = false
            }
        }
    }
    
    func setUser(from dictionary: [String: Any]) {
        if let userDict = dictionary["userData"] as? [String: Any],
           let jsonData = try? JSONSerialization.data(withJSONObject: userDict),
           let decodedUser = try? JSONDecoder().decode(User.self, from: jsonData) {
            self.user = decodedUser
        }
    }
    
    func signOut() {
        isAuthenticated = false
        UserDefaultsService.shared.clearSession()
    }
}
