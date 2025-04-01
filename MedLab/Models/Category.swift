//
//  Category.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 31/3/25.
//

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
    
    var id: Self { self } // Enables Identifiable
    
    var title: String {
        switch self {
        case .reproductiveHealth: return "Reproductive Health"
        case .medicalDevices: return "Medical Devices"
        case .beautyCare: return "Beauty Care"
        case .medicine: return "Medicine"
        case .dietarySupplements: return "Dietary Supplements"
        case .personalCare: return "Personal Care"
        case .sleepSupport: return "Sleep Support"
        case .endurancePerformance: return "Endurance & Performance"
        }
    }
    
    var description: String {
        switch self {
        case .reproductiveHealth:
            return "Contraceptives, fertility tests, ovulation kits"
        case .medicalDevices:
            return "Thermometers, blood pressure monitors, glucometers"
        case .beautyCare:
            return "Face wash, moisturizers, lip balm"
        case .medicine:
            return "Pain relief, antibiotics, allergy meds"
        case .dietarySupplements:
            return "Vitamins, probiotics, omega-3"
        case .personalCare:
            return "Toothpaste, shampoo, deodorant"
        case .sleepSupport:
            return "Melatonin, herbal teas, sleep masks"
        case .endurancePerformance:
            return "Protein bars, creatine, hydration packs"
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
