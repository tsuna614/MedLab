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
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
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
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        
        guard let dictionary = jsonObject as? [String: Any] else {
            throw NSError(domain: "Invalid response data", code: -1)
        }
        
        return dictionary
    }
    
//    func register(user: User, password: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
//        guard let url = URL(string: "http://localhost:3000/auth/register") else {
//            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
//            return
//        }
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
//            receiptsId: user.receiptsId,
//            password: password
//        )
//        
//        do {
//            let jsonData = try JSONEncoder().encode(payload)
//            request.httpBody = jsonData
//            
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                print("Registering with JSON: \(jsonString)")
//            }
//            
//        } catch {
//            completion(.failure(error))
//            return
//        }
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            guard let data = data else {
//                completion(.failure(NSError(domain: "No data received", code: -1)))
//                return
//            }
//            
//            do {
//                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
//                if let dictionary = jsonObject as? [String: Any] {
//                    completion(.success(dictionary))
//                } else {
//                    completion(.failure(NSError(domain: "Invalid JSON structure", code: -1)))
//                }
//            } catch {
//                completion(.failure(error))
//            }
//        }.resume()
//    }
}


