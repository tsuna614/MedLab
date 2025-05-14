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
        static let selectedLanguageRawValue = "selectedLanguageRawValue"
    }

    func setUserId(_ id: String) {
        defaults.set(id, forKey: Keys.userId)
    }

    func setAccessToken(_ token: String) {
        defaults.set(token, forKey: Keys.accessToken)
    }
    
    func setSelectedLanguage(_ language: AppLanguage) {
        defaults.set(language.rawValue, forKey: Keys.selectedLanguageRawValue)
        print("UserDefaultsService: Saved language - \(language.rawValue)")
    }

    func getUserId() -> String? {
        return defaults.string(forKey: Keys.userId)
    }

    func getAccessToken() -> String? {
        return defaults.string(forKey: Keys.accessToken)
    }
    
    func getSelectedLanguage() -> AppLanguage {
        if let rawValue = defaults.string(forKey: Keys.selectedLanguageRawValue),
           let language = AppLanguage(rawValue: rawValue) {
            print("UserDefaultsService: Retrieved language - \(language.rawValue)")
            return language
        }
        print("UserDefaultsService: No stored language found or invalid, defaulting to English.")
        return .english
    }

    func clearSession() {
        defaults.removeObject(forKey: Keys.userId)
        defaults.removeObject(forKey: Keys.accessToken)
    }
}
