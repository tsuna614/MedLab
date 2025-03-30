//
//  AuthService.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 25/3/25.
//

import Foundation

class AuthService {
    static let shared = AuthService()
    private init() {}
    
    func login(email: String, password: String) async throws -> [String: Any] {
        guard let url = URL(string: "http://localhost:3000/auth/login") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginData = LoginRequest(email: email, password: password)
        
        request.httpBody = try JSONEncoder().encode(loginData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            // Attempt to decode error message from response
            if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = errorDict["msg"] as? String {
                throw AuthException.serverError(message)
            } else {
                throw AuthException.unknown
            }
        }
        
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        
        guard let dictionary = jsonObject as? [String: Any],
              let user = dictionary["userData"] as? [String: Any],
              let userId = user["_id"] as? String,
              let accessToken = dictionary["accessToken"] as? String else {
            throw NSError(domain: "Invalid response data", code: -1)
        }
        
        UserDefaultsService.shared.setUserId(userId)
        UserDefaultsService.shared.setAccessToken(accessToken)
        
        return dictionary
    }
    
    func register(user: User, password: String) async throws -> [String: Any] {
        guard let url = URL(string: "http://localhost:3000/auth/register") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create combined payload
        let payload = RegisterRequest(
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            number: user.number,
            userType: user.userType,
            receiptsId: user.receiptsId,
            password: password
        )
        
        request.httpBody = try JSONEncoder().encode(payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            // Attempt to decode error message from response
            if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = errorDict["msg"] as? String {
                throw AuthException.serverError(message)
            } else {
                throw AuthException.unknown
            }
        }
        
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        
        guard let dictionary = jsonObject as? [String: Any] else {
            throw NSError(domain: "Invalid response data", code: -1)
        }
        
        return dictionary
    }
}


