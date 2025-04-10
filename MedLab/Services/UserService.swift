//
//  UserService.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 26/3/25.
//

import Foundation

class UserService {
    static let shared = UserService()
    
    func fetchUser(userId: String, accessToken: String) async throws -> User {
        guard let url = URL(string: "http://localhost:3000/users/\(userId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Await the URLSession call
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Decode to your model
        let user = try JSONDecoder().decode(User.self, from: data)
        return user
    }
}
