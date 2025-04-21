//
//  CartViewModel.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 15/4/25.
//

import SwiftUI

@MainActor
class CartViewModel: ObservableObject {
    @Published private(set) var cartItems: [CartItem] = []
    
    var totalPrice: Double {
        var price: Double = 0
        
        for item in cartItems {
            price += item.totalPrice
        }
        
        return price
    }
    
    var totalQuantity: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    // MARK: - init
    init(sampleData: Bool = false) {
        if sampleData {
            cartItems = [
                CartItem(product: dummyProducts[0], quantity: 2),
                CartItem(product: dummyProducts[1], quantity: 1),
                CartItem(product: dummyProducts[2], quantity: 3),
            ]
        }
    }
    
//    func addProductToCart(product: Product) {
//        let newCart = CartItem(product: product, quantity: 1)
//        
//        for i in 0..<cartItems.count {
//            if (cartItems[i] == newCart) {
//                cartItems[i].quantity += 1
//                return
//            }
//        }
//        cartItems.append(newCart)
//    }
    
    func addProductToCart(product: Product) {
        // Use firstIndex for clarity and efficiency
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[index].quantity += 1
        } else {
            // New item - append (append correctly triggers @Published)
            let newCartItem = CartItem(product: product, quantity: 1)
            cartItems.append(newCartItem)
        }
    }
    
    func increaseQuantity(for product: Product) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[index].quantity += 1
        }
    }
    
    func decreaseQuantity(for product: Product) {
        if let index = cartItems.firstIndex(where:  {$0.product.id == product.id}) {
            if cartItems[index].quantity <= 1 {
                removeItem(item: cartItems[index])
            } else {
                cartItems[index].quantity -= 1
            }
        }
    }
    
    func removeItem(item: CartItem) {
        cartItems.removeAll(where: {$0 == item})
    }
    
    
    func printItems() {
        cartItems.forEach {
            $0.printCart()
        }
    }
}
