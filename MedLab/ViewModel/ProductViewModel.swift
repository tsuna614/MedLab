//
//  ProductViewModel.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 4/4/25.
//

import SwiftUI

@MainActor
class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var hasMore = true
    
    private var currentPage = 1
    private let limit = 10
    private var category: String?
    
    private let productService: ProductServicing
    
    init(category: String? = nil, productService: ProductServicing) {
        self.category = category
        self.productService = productService
    }
    
    func loadInitialProducts() async {
        // Reset state
        currentPage = 1
        hasMore = true
        products = []
        await loadMoreProducts()
    }
    
    func loadMoreProducts() async {
        guard !isLoading && hasMore else { return }
        print("\nLoading")
        isLoading = true
        
        do {
            let response = try await productService.fetchProducts(page: currentPage, limit: limit, category: category)
            products += response.products
            hasMore = response.currentPage < response.totalPages
            currentPage += 1
        } catch {
            print("Failed to load products: \(error)")
        }
        
        print("Loading complete")
        isLoading = false
    }
}
