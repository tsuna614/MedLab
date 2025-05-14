//
//  AppLanguage.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 10/5/25.
//

import Foundation

enum AppLanguage: String, CaseIterable, Identifiable, Hashable {
    case systemDefault = "(System Default)"
    case english       = "English"
    case french        = "Français"
    case japanese      = "日本語"
    case spanish       = "Español"
    case vietnamese    = "Tiếng Việt"

    var id: String { self.rawValue }

    var localeIdentifier: String {
        switch self {
        case .english:          return "en"
        case .french:           return "fr"
        case .japanese:         return "ja"
        case .spanish:          return "es"
        case .vietnamese:       return "vi"
        default: return "default"
        }
    }

    static func from(localeIdentifier: String) -> AppLanguage? {
        switch localeIdentifier.lowercased() {
        case "en": return .english
        case "fr": return .french
        case "ja": return .japanese
        case "es": return .spanish
        case "vi": return .vietnamese
        default:
            print("Warning: Unknown locale identifier '\(localeIdentifier)', returning to system default.")
            return .systemDefault
        }
    }
}
