//
//  ProductListView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 31/3/25.
//

import SwiftUI

struct ProductListView: View {
//    @StateObject var productService: ProductService
    @StateObject var viewModel: ProductViewModel
    
    var category: String?
    
    init(category: String? = nil) {
        let productServiceInstance = ProductService(apiClient: ApiClient(baseURLString: base_url))
//        _productService = StateObject(wrappedValue: productServiceInstance)
        _viewModel = StateObject(wrappedValue: ProductViewModel(category: category, productService: productServiceInstance))
//        viewModel = ProductViewModel(category: category)
        self.category = category
    }
    
    func loadMoreProducts() {
        Task { await viewModel.loadMoreProducts() }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ProductGridListView(productViewModel: viewModel, products: viewModel.products)
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
            }
        }
        .navigationTitle(category ?? "")
        .task {
            await viewModel.loadInitialProducts()
        }
    }
}

