//
//  User.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 26/3/25.
//

import Foundation

struct User: Codable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let number: String?
    let userType: String?
    let receiptsId: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id" // because the id from JSON field name is "_id"
        case email
        case firstName
        case lastName
        case number
        case userType
        case receiptsId
    }
}
