//
//  CheckoutView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 23/4/25.
//
import SwiftUI

struct CheckoutView: View {
    // 1. Add EnvironmentObject to access the CartViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    
    // State for address/payment selection would go here eventually
    // @State private var selectedAddress: Address?
    // @State private var selectedPayment: PaymentMethod?
    
    let singleProduct: Product?
    
    // Placeholders for display (keep for now or replace with state)
    private var placeholderAddress = "123 Shipping Ln\nCupertino, CA 95014\nUnited States"
    private var placeholderPayment = "Visa ending in 4242"
    
    init(singleProduct: Product?) {
        self.singleProduct = singleProduct
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // --- Shipping Address Section ---
                    SectionBox {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Shipping Address")
                                    .font(.title3.weight(.semibold))
                                Text(placeholderAddress)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 2)
                            }
                            Spacer()
                            Button("Change") { print("Change Address Tapped") }
                                .font(.callout)
                        }
                    }
                    
                    // --- Payment Method Section ---
                    SectionBox {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Payment Method")
                                    .font(.title3.weight(.semibold))
                                HStack {
                                    Image(systemName: "creditcard.fill")
                                        .foregroundColor(.blue)
                                    Text(placeholderPayment)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.top, 2)
                            }
                            Spacer()
                            Button("Change") { print("Change Payment Tapped") }
                                .font(.callout)
                        }
                    }
                    
                    // --- Order Summary Section ---
                    // Now uses the real CartViewModel data
                    VStack(alignment: .leading) {
                        Text("Order Summary")
                            .font(.title3.weight(.semibold))
                            .padding(.horizontal)
                        // Pass the ViewModel data implicitly via EnvironmentObject
                        if singleProduct != nil {
                            SingleProductCheckoutSummaryView(singleProduct: singleProduct!)
                        } else {
                            CheckoutSummaryView() // Renamed from Placeholder
                        }
                    }
                    
                    Spacer()
                    
                }
                .padding(.vertical)
                
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            
            // --- Place Order Button ---
            .safeAreaInset(edge: .bottom) {
                Button {
                    print("Place Order Tapped!")
                } label: {
                    // Display total price on the button as well
                    Text("Place Order - \(String(format: "$%.2f", calculateFinalTotal()))") // Calculate total
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 8)
                .background(.regularMaterial)
                // Disable button if cart is empty
                .disabled(cartViewModel.cartItems.isEmpty && (singleProduct == nil))
            }
        }
    }
    
    // Helper function to calculate total including potential shipping/tax
    // For now, it just returns the cartViewModel's total price
    private func calculateFinalTotal() -> Double {
        // Add shipping, tax calculations here when available
        let shippingCost: Double = 5.00 // Example
        let taxAmount: Double = cartViewModel.totalPrice * 0.08 // Example 8% tax
        return cartViewModel.totalPrice + shippingCost + taxAmount
    }
}

// Helper View for consistent section styling (Keep as is)
struct SectionBox<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        VStack(alignment: .leading) { content }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(10)
            .padding(.horizontal)
    }
}


// Renamed and updated Summary View using CartViewModel
struct CheckoutSummaryView: View {
    // 2. Access the ViewModel here too
    @EnvironmentObject var cartViewModel: CartViewModel
    
    // Example fixed shipping and tax calculation (move logic elsewhere eventually)
    let shippingCost: Double = 5.00
    var taxAmount: Double { cartViewModel.totalPrice * 0.08 } // 8% tax
    var total: Double { cartViewModel.totalPrice + shippingCost + taxAmount }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Optional: Could add a mini list of item names here
            // ForEach(cartViewModel.cartItems.prefix(3)) { item in Text(item.product.name)... }
            
            Divider()
            
            HStack {
                // 3. Use ViewModel data for item count and subtotal
                Text("Subtotal (\(cartViewModel.totalQuantity) items)")
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "$%.2f", cartViewModel.totalPrice))
                    .font(.body.weight(.medium))
            }
            HStack {
                Text("Shipping")
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "$%.2f", shippingCost))
                    .font(.body.weight(.medium))
            }
            HStack {
                Text("Estimated Tax")
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "$%.2f", taxAmount))
                    .font(.body.weight(.medium))
            }
            
            Divider()
            
            HStack {
                Text("Total")
                    .font(.headline)
                Spacer()
                // 4. Use calculated total
                Text(String(format: "$%.2f", total))
                    .font(.headline)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// temporary for single product, implement better logic later
struct SingleProductCheckoutSummaryView: View {
    var singleProduct: Product
    
    // Example fixed shipping and tax calculation (move logic elsewhere eventually)
    let shippingCost: Double = 5.00
    var taxAmount: Double { singleProduct.price * 0.08 } // 8% tax
    var total: Double { singleProduct.price + shippingCost + taxAmount }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Optional: Could add a mini list of item names here
            // ForEach(cartViewModel.cartItems.prefix(3)) { item in Text(item.product.name)... }
            
            Divider()
            
            HStack {
                // 3. Use ViewModel data for item count and subtotal
                Text("Subtotal (1 items)")
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "$%.2f", singleProduct.price))
                    .font(.body.weight(.medium))
            }
            HStack {
                Text("Shipping")
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "$%.2f", shippingCost))
                    .font(.body.weight(.medium))
            }
            HStack {
                Text("Estimated Tax")
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "$%.2f", taxAmount))
                    .font(.body.weight(.medium))
            }
            
            Divider()
            
            HStack {
                Text("Total")
                    .font(.headline)
                Spacer()
                // 4. Use calculated total
                Text(String(format: "$%.2f", total))
                    .font(.headline)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
