//
//  ProductCard.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 6/4/25.
//

import SwiftUI

struct ProductCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: product.imageUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 120, height: 120)
            .clipped()
            .cornerRadius(10)
            
            Text(product.name)
                .font(.headline)
                .lineLimit(2)
            
            Text(String(format: "$%.2f", product.price))
                .font(.subheadline)
                .foregroundColor(.green)
            
            Text("Stock: \(product.stock)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 140)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
