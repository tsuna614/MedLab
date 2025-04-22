//
//  ProductGridListView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 4/4/25.
//

import SwiftUI

struct ProductGridListView: View {
    var productViewModel: ProductViewModel
    let products: [Product]
    let columns = [GridItem(.flexible()), GridItem(.flexible())] // 2-column layout
    
    var body: some View {
        Group {
            if products.isEmpty && !productViewModel.isLoading {
                Text("No product found")
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(products) { product in
                            NavigationLink(destination: ProductDetailView(product: product)) {
                                ProductCard(product: product)
                                    .onAppear {
                                        // Trigger next page when last item appears
                                        if product == productViewModel.products.last {
                                            Task { await productViewModel.loadMoreProducts() }
                                        }
                                    }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
        }
    }
}
