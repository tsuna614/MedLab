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
    case spanish       = "Español"
    case vietnamese    = "Tiếng Việt"
    case japanese      = "日本語"
    case chinese       = "简体中文"
    case german        = "Deutsch"
    case russian       = "Русский"

    var id: String { self.rawValue }

    var localeIdentifier: String {
        switch self {
        case .english:          return "en"
        case .french:           return "fr"
        case .spanish:          return "es"
        case .vietnamese:       return "vi"
        case .japanese:         return "ja"
        case .chinese:          return "zh-Hans"
        case .german:           return "de"
        case .russian:          return "ru"
        default: return "default"
        }
    }

    static func from(localeIdentifier: String) -> AppLanguage? {
        switch localeIdentifier.lowercased() {
        case "en": return .english
        case "fr": return .french
        case "es": return .spanish
        case "vi": return .vietnamese
        case "ja": return .japanese
        case "zh-Hans": return .chinese
        case "de": return .german
        case "ru": return .russian
        default:
            print("Warning: Unknown locale identifier '\(localeIdentifier)', returning to system default.")
            return .systemDefault
        }
    }
}
