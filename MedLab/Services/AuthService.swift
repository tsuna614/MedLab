//
//  AuthService.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 25/3/25.
//

import Foundation

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let msg: String
    let accessToken: String
    let refreshToken: String
    let userData: User
}

struct RegisterRequest: Codable {
    let email: String
    let firstName: String
    let lastName: String
    let number: String?
    let userType: String?
    let usedVouchersCode: [String]?
    let password: String
}

protocol AuthServicing {
    func login(email: String, password: String) async throws -> LoginResponse
    func register(user: User, password: String) async throws -> User
}

class AuthService: AuthServicing, ObservableObject {
    private let apiClient: ApiClient
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    func login(email: String, password: String) async throws -> LoginResponse {
        print("AuthService: Login...")
        let requestBody = LoginRequest(email: email, password: password)
        
        return try await apiClient.request(
            endpoint: .login,
            body: requestBody,
            responseType: LoginResponse.self
        )
    }
    
    func register(user: User, password: String) async throws -> User {
        print("AuthService: Signin...")
        let requestBody = RegisterRequest(
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            number: user.number,
            userType: user.number,
            usedVouchersCode: user.usedVouchersCode,
            password: password
        )
        
        return try await apiClient.request(
            endpoint: .register,
            body: requestBody,
            responseType: User.self
        )
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        // Create combined payload
//        let payload = RegisterRequest(
//            email: user.email,
//            firstName: user.firstName,
//            lastName: user.lastName,
//            number: user.number,
//            userType: user.userType,
//            usedVouchersCode: user.usedVouchersCode,
//            password: password
//        )
//        
//        request.httpBody = try JSONEncoder().encode(payload)
//        
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw URLError(.badServerResponse)
//        }
//        
//        if !(200...299).contains(httpResponse.statusCode) {
//            // Attempt to decode error message from response
//            if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//               let message = errorDict["msg"] as? String {
//                throw AuthException.serverError(message)
//            } else {
//                throw AuthException.unknown
//            }
//        }
//        
//        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
//        
//        guard let dictionary = jsonObject as? [String: Any] else {
//            throw NSError(domain: "Invalid response data", code: -1)
//        }
//        
//        return dictionary
    }
}


