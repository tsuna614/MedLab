//
//  Category.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 31/3/25.
//

import Foundation
import SwiftUI

import Foundation
import SwiftUI

enum ProductCategory: CaseIterable, Identifiable {
    case reproductiveHealth
    case medicalDevices
    case beautyCare
    case medicine
    case dietarySupplements
    case personalCare
    case sleepSupport
    case endurancePerformance

    var id: Self { self }

    var title: LocalizedStringKey {
//        switch self {
//        case .reproductiveHealth:
//            return NSLocalizedString("Reproductive Health", comment: "")
//        case .medicalDevices:
//            return NSLocalizedString("Medical Devices", comment: "")
//        case .beautyCare:
//            return NSLocalizedString("Beauty Care", comment: "")
//        case .medicine:
//            return NSLocalizedString("Medicine", comment: "")
//        case .dietarySupplements:
//            return NSLocalizedString("Dietary Supplements", comment: "")
//        case .personalCare:
//            return NSLocalizedString("Personal Care", comment: "")
//        case .sleepSupport:
//            return NSLocalizedString("Sleep Support", comment: "")
//        case .endurancePerformance:
//            return NSLocalizedString("Endurance & Performance", comment: "")
//        }
        switch self {
        case .reproductiveHealth:
            "Reproductive Health"
        case .medicalDevices:
            "Medical Devices"
        case .beautyCare:
            "Beauty Care"
        case .medicine:
            "Medicine"
        case .dietarySupplements:
            "Dietary Supplements"
        case .personalCare:
            "Personal Care"
        case .sleepSupport:
            "Sleep Support"
        case .endurancePerformance:
            "Endurance & Performance"
        }
    }
    
    var rawTitleValue: String {
        switch self {
        case .reproductiveHealth:
            "Reproductive Health"
        case .medicalDevices:
            "Medical Devices"
        case .beautyCare:
            "Beauty Care"
        case .medicine:
            "Medicine"
        case .dietarySupplements:
            "Dietary Supplements"
        case .personalCare:
            "Personal Care"
        case .sleepSupport:
            "Sleep Support"
        case .endurancePerformance:
            "Endurance & Performance"
        }
    }

    var description: LocalizedStringKey {
//        switch self {
//        case .reproductiveHealth:
//            return NSLocalizedString("Contraceptives, fertility tests, ovulation kits", comment: "")
//        case .medicalDevices:
//            return NSLocalizedString("Thermometers, blood pressure monitors, glucometers", comment: "")
//        case .beautyCare:
//            return NSLocalizedString("Face wash, moisturizers, lip balm", comment: "")
//        case .medicine:
//            return NSLocalizedString("Pain relief, antibiotics, allergy meds", comment: "")
//        case .dietarySupplements:
//            return NSLocalizedString("Vitamins, probiotics, omega-3", comment: "")
//        case .personalCare:
//            return NSLocalizedString("Toothpaste, shampoo, deodorant", comment: "")
//        case .sleepSupport:
//            return NSLocalizedString("Melatonin, herbal teas, sleep masks", comment: "")
//        case .endurancePerformance:
//            return NSLocalizedString("Protein bars, creatine, hydration packs", comment: "")
//        }
        switch self {
        case .reproductiveHealth:
            "Contraceptives, fertility tests, ovulation kits"
        case .medicalDevices:
            "Thermometers, blood pressure monitors, glucometers"
        case .beautyCare:
            "Face wash, moisturizers, lip balm"
        case .medicine:
            "Pain relief, antibiotics, allergy meds"
        case .dietarySupplements:
            "Vitamins, probiotics, omega-3"
        case .personalCare:
            "Toothpaste, shampoo, deodorant"
        case .sleepSupport:
            "Melatonin, herbal teas, sleep masks"
        case .endurancePerformance:
            "Protein bars, creatine, hydration packs"
        }
    }

    var imagePath: String {
        switch self {
        case .reproductiveHealth: return "reproductive_icon"
        case .medicalDevices: return "devices_icon"
        case .beautyCare: return "beauty_icon"
        case .medicine: return "medicine_icon"
        case .dietarySupplements: return "supplements_icon"
        case .personalCare: return "personal_icon"
        case .sleepSupport: return "sleep_icon"
        case .endurancePerformance: return "performance_icon"
        }
    }

    var color: Color {
        switch self {
        case .reproductiveHealth: return .pink
        case .medicalDevices: return .blue
        case .beautyCare: return .purple
        case .medicine: return .green
        case .dietarySupplements: return .orange
        case .personalCare: return .yellow
        case .sleepSupport: return .indigo
        case .endurancePerformance: return .red
        }
    }
}
