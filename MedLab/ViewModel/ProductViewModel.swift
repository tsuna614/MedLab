//
//  ProductViewModel.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 4/4/25.
//

import SwiftUI

class ProductViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var hasMore = true
    
    private var currentPage = 1
    private let limit = 10
    private var category: String?
    
    init(category: String? = nil) {
        self.category = category
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
            let response = try await ProductService.shared.fetchProduct(page: currentPage, limit: limit, category: category)
            products += response.products
            hasMore = currentPage < response.totalPages
            currentPage += 1
        } catch {
            print("Failed to load products: \(error)")
        }
        
        print("Loading complete")
        isLoading = false
    }
}
