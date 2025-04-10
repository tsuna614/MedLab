//
//  ProductHorizontalListView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 3/4/25.
//

import SwiftUI

struct ProductHorizontalListView: View {
    @EnvironmentObject var productViewModel: ProductViewModel
    let products: [Product]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(products) { product in
                    ProductCard(product: product)
                        .onAppear {
                            // Trigger next page when last item appears
                            if product == productViewModel.products.last {
                                Task { await productViewModel.loadMoreProducts() }
                            }
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}
