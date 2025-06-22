//
//  Voucher.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 19/6/25.
//

import Foundation

struct Voucher: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let code: String
    let discount: Int
    let expiryDate: Date
    let isVisible: Bool
    
    var isExpired: Bool {
        if self.expiryDate < Date() {
            return true
        } else {
            return false
        }
    }
    

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case description
        case code
        case discount
        case expiryDate
        case isVisible = "isVisibleToUsers"
    }
}
