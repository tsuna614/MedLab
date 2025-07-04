//
//  UserService.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 26/3/25.
//

import Foundation

struct UpdateUserRequest: Encodable {
    let email: String
    let firstName: String
    let lastName: String
    let number: String?
    let userType: String?
    let usedVouchersCode: [String]?
    let address: Address?
}

struct UpdateUserResponse: Codable {
    let msg: String
}

protocol UserServicing {
    func fetchUser() async throws -> User
    func updateUser(user: User) async throws -> UpdateUserResponse
}

class UserService: UserServicing, ObservableObject {
    private let apiClient: ApiClient
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    func fetchUser() async throws -> User {
        print("UserService: Fetching user...")
        
        return try await apiClient.request(
            endpoint: .fetchUser,
            body: Optional<EmptyBody>.none,
            responseType: User.self
        )
        
//        guard let url = URL(string: "http://localhost:3000/users/\(userId)") else {
//            throw URLError(.badURL)
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        
//        // Await the URLSession call
//        let (data, _) = try await URLSession.shared.data(for: request)
//        
//        // Decode to your model
//        let user = try JSONDecoder().decode(User.self, from: data)
//        return user
        
    }
    
    func updateUser(user: User) async throws -> UpdateUserResponse {
        print("UserService: Updating user...")
        
        let requestBody = UpdateUserRequest(
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            number: user.number,
            userType: user.userType,
            usedVouchersCode: user.usedVouchersCode,
            address: user.address
        )
        
        return try await apiClient.request(
            endpoint: .updateUser,
            body: requestBody,
            responseType: UpdateUserResponse.self
        )
    }
}
