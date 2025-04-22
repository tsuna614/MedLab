//
//  SearchView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 30/3/25.
//

import SwiftUI

struct ProductView: View {
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TopBar(title: "Product")
                
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Categories")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding([.top, .leading, .trailing])
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(ProductCategory.allCases) { category in
                                    CategoryCard(width: 160, showingDescription: false, category: category)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Divider()
                            .padding(.top)
                        
                        Text("Products List")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding([.top, .leading, .trailing])
                        
                        ProductListView()
                    }
                }
            }
            .navigationTitle("Product")
            .navigationBarHidden(true)
//            .navigationBarTitleDisplayMode(.inline) // Force title into the compact bar
        }
    }
}
