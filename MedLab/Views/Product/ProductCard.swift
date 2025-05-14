//
//  ProductCard.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 6/4/25.
//

import SwiftUI

struct ProductCard: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var snackbarViewModel: SnackBarViewModel
    
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
            
            HStack(alignment: .center) {
                Button {
                    Task {
                        snackbarViewModel.showSnackbar(message: "\(product.name) added to Cart")
                        await cartViewModel.addProductToCart(product: product)
                    }
                } label: {
                    Image(systemName: "cart")
                        .font(.title2)
                }
                .padding(8)
//                .frame(maxHeight: .infinity)
                .overlay( // Draw on top of the button's frame
                    RoundedRectangle(cornerRadius: 8) // Create the shape
                        .stroke(Color.blue, lineWidth: 1.5) // Stroke the outline
                )
                
                NavigationLink {
                    CheckoutView()
                    // Environment objects like CartViewModel are usually inherited automatically
                    // from the parent navigation context.
                } label: {
                    // Label: How the link looks (identical to the old button)
                    Text("Buy Now") // Or "Proceed to Checkout" if you want to rename
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
//        .frame(width: 160)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
