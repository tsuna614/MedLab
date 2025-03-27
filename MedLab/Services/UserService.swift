//
//  UserService.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 26/3/25.
//

import Foundation

class UserService {
    static let shared = UserService()

    func fetchUser(userId: String, accessToken: String, completion: @escaping (Result<User, Error>) -> Void) {
        // Simulate network delay and dummy user
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            // Just simulate success for now
            let dummyUser = User(
                email: "demo@example.com",
                firstName: "Demo",
                lastName: "User",
                number: "0000000000",
                userType: "customer",
                receiptsId: []
            )
            completion(.success(dummyUser))

            // If you want to simulate failure:
            // completion(.failure(NSError(domain: "Token expired", code: 401)))
        }
    }
}
