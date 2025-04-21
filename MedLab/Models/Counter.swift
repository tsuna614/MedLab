//
//  Counter.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 21/4/25.
//

import Foundation

struct Counter: Identifiable {
    let id = UUID()
    let name: String = "Lol"
    var count: Int
    
    func printCounter() {
        print("id: \(id)\nCount: \(count)")
    }
}
