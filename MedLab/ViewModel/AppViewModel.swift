//
//  AppViewModel.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 26/3/25.
//

import SwiftUI

@MainActor // to remove DispatchQueue.main.async blocks, because Swift will automatically run my code on the main thread
class AppViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = true
    @Published var user: User?
    
    @Published var shouldPopToRoot: Bool = false
    @Published var selectedTab: Int = 0
    
    private let userService: UserServicing
    
    // MARK: - init
    init(userService: UserServicing) {
//        let apiClientInstance = ApiClient(baseURLString: "http://localhost:3000")
//        let userServiceInstance = UserService(apiClient: apiClientInstance)
//        _userService = StateObject(wrappedValue: userServiceInstance)
        self.userService = userService
        
        checkStoredCredentials()
    }
    
    func checkStoredCredentials() {
        guard
            (UserDefaultsService.shared.getUserId() != nil),
            (UserDefaultsService.shared.getAccessToken() != nil)
        else {
            isAuthenticated = false
            isLoading = false
            return
        }
        
        Task {
            do {
                let fetchedUser = try await userService.fetchUser()
                self.user = fetchedUser
                self.isAuthenticated = true
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
    
    func updateUser(newUser: User) {
        Task {
            do {
                let response = try await userService.updateUser(user: newUser)
                print(response)
                setUser(newUser)
            } catch {
                print("❌ AppViewModel: Update user failed: \(error.localizedDescription)")
            }
        }
    }
    
    func setUser(_ user: User) {
        self.user = user
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
