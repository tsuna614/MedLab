//
//  Doctor.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 11/6/25.
//

import Foundation
import SwiftUI

struct Doctor: Codable, Identifiable {
    let id: String
    let firstName: String
    let lastName: String
    let profileImageUrl: String?

    let medicalSpecialty: String
    let qualifications: String?
    let startingYear: Int
    
    let shortBio: String?

    let consultationFeeRange: String?
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    var yearsOfExperience: Int {
        return Calendar.current.component(.year, from: Date()) - startingYear + 1
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case firstName
        case lastName
        case profileImageUrl
        case medicalSpecialty
        case qualifications
        case startingYear
        case shortBio
        case consultationFeeRange
    }
}

// MARK: - Dummy Data for Previews/Testing

extension Doctor {
    static var sampleDoctors: [Doctor] {
        return [
            Doctor(
                id: "doc_001",
                firstName: "Alice",
                lastName: "Smith",
                profileImageUrl: nil, // Add placeholder URL or actual image name later
                medicalSpecialty: "Cardiology, Internal Medicine",
                qualifications: "MD, Stanford University. Board Certified in Cardiology.",
                startingYear: 2020,
                shortBio: "Dedicated cardiologist with a focus on preventative care and patient education.",
                consultationFeeRange: "$200 - $300"
            ),
            Doctor(
                id: "doc_002",
                firstName: "Robert",
                lastName: "Jones",
                profileImageUrl: nil,
                medicalSpecialty: "Pediatrics",
                qualifications: "MBBS, Johns Hopkins University. Fellow of AAP.",
                startingYear: 2020,
                shortBio: "Experienced pediatrician passionate about child development and immunizations.",
                consultationFeeRange: "$150 - $250"
            ),
            Doctor(
                id: "doc_003",
                firstName: "Emily",
                lastName: "White",
                profileImageUrl: nil,
                medicalSpecialty: "Dermatology",
                qualifications: "MD, Yale University. especializada en dermatología cosmética.",
                startingYear: 2020,
                shortBio: "Specializing in cosmetic dermatology and advanced skin treatments.",
                consultationFeeRange: "$180 - $280"
            )
        ]
    }
}
