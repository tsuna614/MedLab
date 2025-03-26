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

    func login(username: String, password: String, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        guard let url = URL(string: "https://your-api.com/login") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let loginData = LoginRequest(username: username, password: password)

        do {
            request.httpBody = try JSONEncoder().encode(loginData)
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}


