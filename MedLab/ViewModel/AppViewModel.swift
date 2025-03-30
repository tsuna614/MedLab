//
//  AppViewModel.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 26/3/25.
//

import SwiftUI

@MainActor // to remove DispatchQueue.main.async blocks, because Swift will automatically run your code on the main thread
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
            isAuthenticated = false
            isLoading = false
            return
        }
        
        Task {
            do {
                user = try await UserService.shared.fetchUser(userId: userId, accessToken: token)
                isAuthenticated = true
            } catch {
                print("Fetch user failed: \(error.localizedDescription)")
                isAuthenticated = false
            }
            isLoading = false
        }
    }
    
    func setUserFromJSON(from dictionary: [String: Any]) {
        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary),
           let decodedUser = try? JSONDecoder().decode(User.self, from: jsonData) {
            self.user = decodedUser
        }
    }
    
    func signOut() {
        isAuthenticated = false
        UserDefaultsService.shared.clearSession()
    }
}
