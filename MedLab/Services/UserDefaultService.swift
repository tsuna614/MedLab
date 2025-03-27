//
//  UserDefaultService.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 26/3/25.
//

import Foundation

class UserDefaultsService {
    static let shared = UserDefaultsService()
    private let defaults = UserDefaults.standard

    private init() {}

    private enum Keys {
        static let userId = "userId"
        static let accessToken = "accessToken"
    }

    func setUserId(_ id: String) {
        defaults.set(id, forKey: Keys.userId)
    }

    func setAccessToken(_ token: String) {
        defaults.set(token, forKey: Keys.accessToken)
    }

    func getUserId() -> String? {
        return defaults.string(forKey: Keys.userId)
    }

    func getAccessToken() -> String? {
        return defaults.string(forKey: Keys.accessToken)
    }

    func clearSession() {
        defaults.removeObject(forKey: Keys.userId)
        defaults.removeObject(forKey: Keys.accessToken)
    }
}
