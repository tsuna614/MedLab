//
//  CheckoutViewModel.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 25/4/25.
//

import SwiftUI

@MainActor
class CheckoutViewModel: ObservableObject {
    private var cartViewModel: CartViewModel?
    private var product: Product?
    
    init(cartViewModel: CartViewModel? = nil, product: Product? = nil) {
        self.cartViewModel = cartViewModel
        self.product = product
    }
}
