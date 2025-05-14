//
//  LanguageSettingsObserver.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 13/5/25.
//

import SwiftUI

@MainActor
class LanguageSettingsObserver: ObservableObject {
    @Published var currentLocaleIdentifier: String

    init() {
        // Initialize with the currently saved language
        let initialLanguage = UserDefaultsService.shared.getSelectedLanguage()
        self.currentLocaleIdentifier = initialLanguage.localeIdentifier
        print("LanguageSettingsObserver: Initial locale set to \(self.currentLocaleIdentifier)")

        // Optional: Listen for external changes if language can be set elsewhere
        // Or, more commonly, have SettingsView update this object.
    }

    // Method to update the language (called from SettingsView or elsewhere)
    func updateLanguage(to language: AppLanguage) {
        UserDefaultsService.shared.setSelectedLanguage(language)
        if self.currentLocaleIdentifier != language.localeIdentifier {
            self.currentLocaleIdentifier = language.localeIdentifier
            print("LanguageSettingsObserver: Locale changed to \(self.currentLocaleIdentifier)")
        }
    }
}
