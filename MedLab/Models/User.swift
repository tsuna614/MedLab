//
//  User.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 26/3/25.
//

import Foundation

struct User: Codable {
    let email: String
    let firstName: String
    let lastName: String
    let number: String?
    let userType: String?
    let receiptsId: [String]?
}
