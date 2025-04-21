//
//  CartItem.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 13/4/25.
//

import Foundation

struct CartItem: Identifiable, Equatable {
    let id: String
    let product: Product
    var quantity: Int
    
    // Computed property for the total price of this line item
    var totalPrice: Double {
        return product.price * Double(quantity)
    }
    
    init(id: String = UUID().uuidString, product: Product, quantity: Int) {
        self.id = id
        self.product = product
        self.quantity = quantity
    }
    
    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        lhs.product.id == rhs.product.id // Compare based on the product ID
    }
    
    func printCart() {
        print("id: \(id)\nquantity: \(quantity)")
    }
}
