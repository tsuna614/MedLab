//
//  ProductDetailView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 6/4/25.
//

import SwiftUI

struct ProductDetailView: View {
    let product: Product

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Image
                if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity, maxHeight: 250)
                    .cornerRadius(12)
//                    .background(Color.gray.opacity(0.1))
                }

                // Name & Brand
                Text(product.name)
                    .font(.title2)
                    .fontWeight(.semibold)

                if let brand = product.brand {
                    Text("Brand: \(brand)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Divider()

                // Price & Stock
                HStack {
                    Text(String(format: "$%.2f", product.price))
                        .font(.title3)
                        .fontWeight(.bold)

                    Spacer()

                    Text("Stock: \(product.stock)")
                        .foregroundColor(product.stock > 0 ? .green : .red)
                        .font(.subheadline)
                }

                // Category & Strength
                if let category = product.category {
                    Text("Category: \(category)")
                        .font(.subheadline)
                }

                if let strength = product.strength {
                    Text("Strength: \(strength)")
                        .font(.subheadline)
                }

                if let dosageForm = product.dosageForm {
                    Text("Form: \(dosageForm)")
                        .font(.subheadline)
                }

                if let ingredients = product.ingredients, !ingredients.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ingredients:")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text(ingredients.joined(separator: ", "))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }

                if product.prescriptionRequired {
                    Text("Prescription Required")
                        .font(.footnote)
                        .padding(6)
                        .background(Color.red.opacity(0.2))
                        .foregroundColor(.red)
                        .cornerRadius(6)
                }

                if let expiryDate = product.expiryDate {
                    Text("Expires: \(expiryDate)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                if let manufacturer = product.manufacturer {
                    Text("Manufacturer: \(manufacturer)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                if let instructions = product.instructions {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Instructions:")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text(instructions)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Product Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
