//
//  ProductListView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 31/3/25.
//

import SwiftUI

struct ProductListView: View {
    @StateObject var viewModel: ProductViewModel
    
    var category: String?
    
    init(category: String? = nil) {
        _viewModel = StateObject(wrappedValue: ProductViewModel(category: category))
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
        .task {
            await viewModel.loadInitialProducts()
        }
    }
}

