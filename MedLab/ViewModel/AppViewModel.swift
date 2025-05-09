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
    
    @Published var shouldPopToRoot: Bool = false // Signal to reset navigation
    @Published var selectedTab: Int = 0 // Example if using programmatic tab switching
    
    // MARK: - init
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
                let fetchedUser = try await UserService.shared.fetchUser(userId: userId, accessToken: token)
                self.user = fetchedUser // Store fetched user
                self.isAuthenticated = true // Mark as authenticated
                print("AppViewModel: User authenticated via stored credentials. User: \(fetchedUser.email)")
            } catch {
                print("❌ AppViewModel: Fetch user with stored credentials failed: \(error.localizedDescription)")
                self.isAuthenticated = false
                self.user = nil // Clear user data on failure
                UserDefaultsService.shared.clearSession() // Clear invalid stored session
            }
            self.isLoading = false
        }
    }
    
    func setUserFromJSON(from dictionary: [String: Any]) {
        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary),
           let decodedUser = try? JSONDecoder().decode(User.self, from: jsonData) {
            self.user = decodedUser
        } else {
            print("⚠️ AppViewModel: Failed to decode user from dictionary.")
       }
    }
    
    func signOut() {
        isAuthenticated = false
        UserDefaultsService.shared.clearSession()
    }
}
