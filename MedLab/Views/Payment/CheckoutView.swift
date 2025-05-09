//
//  CheckoutView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 23/4/25.
//

import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject var orderViewModel: OrderViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    
    // --- Passed Parameter ---
    let singleProduct: Product? // Still needed if supporting "Buy Now" flow
    
    // --- UI State ---
    @State private var shippingRecipient: String = "Jane Doe" // Example state for form
    @State private var shippingStreet: String = "123 Main St"
    @State private var shippingCity: String = "Anytown"
    @State private var shippingState: String = "CA"
    @State private var shippingPostalCode: String = "12345"
    @State private var shippingCountry: String = "USA"
    @State private var paymentInfo: String? = "Visa ending in 4242" // Example
    
    // --- Navigation State ---
    @State private var navigateToOrderConfirmation: Bool = false
    
    // --- Default Initializer (or provide one if needed just for singleProduct) ---
    init(singleProduct: Product? = nil) { // Made optional default to nil
        self.singleProduct = singleProduct
        print("CheckoutView initialized for product: \(singleProduct?.name ?? "Cart")")
        // IMPORTANT: singleProduct logic needs to be fully integrated into placeOrder
        //            if you want "Buy Now" -> "Place Order" to work directly.
        //            Current implementation assumes Place Order uses the cart.
    }
    
    
    var body: some View {
        let _ = Self._printChanges() // Debug helper
        
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // --- Shipping Address Section ---
                    SectionBox {
                        VStack(alignment: .leading){
                            Text("Shipping Address").font(.title3.weight(.semibold))
                            // TODO: Replace Text with actual TextField/Form elements bound to @State vars
                            Text("\(shippingRecipient)\n\(shippingStreet)\n\(shippingCity), \(shippingState) \(shippingPostalCode)\n\(shippingCountry)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        // Add Change Button logic if needed
                    }
                    
                    // --- Payment Method Section ---
                    SectionBox {
                        VStack(alignment: .leading){
                            Text("Payment Method").font(.title3.weight(.semibold))
                            // TODO: Replace Text with actual payment selection UI
                            Text(paymentInfo ?? "N/A")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        // Add Change Button logic if needed
                    }
                    
                    // --- Order Summary Section ---
                    VStack(alignment: .leading) {
                        Text("Order Summary")
                            .font(.title3.weight(.semibold))
                            .padding(.horizontal)
                        
                        // Use appropriate summary view based on context
                        if let product = singleProduct {
                            // TODO: Adapt placeOrder logic to handle single product if needed
                            SingleProductCheckoutSummaryView(singleProduct: product)
                        } else {
                            // Uses cartViewModel from environment
                            CheckoutSummaryView()
                        }
                    }
                    Spacer()
                }
                .padding(.vertical)
                // Show error Alert using OrderViewModel's state
                .alert("Order Error", isPresented: .constant(orderViewModel.placementErrorMessage != nil), actions: {
                    Button("OK") { orderViewModel.placementErrorMessage = nil } // Clear error
                }) {
                    Text(orderViewModel.placementErrorMessage ?? "An unknown error occurred.")
                }
                
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            // Navigate to confirmation based on OrderViewModel's state
            .navigationDestination(isPresented: $navigateToOrderConfirmation) {
                // Pass the newly placed order from OrderViewModel
                if let order = orderViewModel.newlyPlacedOrder {
                    OrderConfirmationView(order: order)
                } else {
                    Text("Order Confirmed (Details Pending)") // Fallback
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    // --- Trigger Order Placement ---
                    // TODO: Adapt this logic if handling singleProduct checkout differently.
                    // Currently assumes placing order from the cart.
                    if singleProduct != nil {
                        print("WARN: Placing single product order not fully implemented in ViewModel yet.")
                        // Add specific logic or prevent this path for now
                        orderViewModel.placementErrorMessage = "Buy Now -> Place Order not implemented."
                        return
                    }
                    
                    // Create address object from state vars
                    let currentShippingAddress = ShippingAddress(
                        recipientName: shippingRecipient, street: shippingStreet, city: shippingCity,
                        state: shippingState, postalCode: shippingPostalCode, country: shippingCountry, phoneNumber: nil
                    )
                    // Call the SHARED OrderViewModel's placeOrder method
                    Task {
                        await orderViewModel.placeOrder(
                            shippingAddress: currentShippingAddress,
                            paymentDetails: paymentInfo
                        )
                        // Trigger navigation if successful
                        if orderViewModel.orderPlacedSuccessfully {
                            navigateToOrderConfirmation = true
                        }
                    }
                } label: {
                    HStack {
                        // Use OrderViewModel's loading state
                        if orderViewModel.isPlacingOrder {
                            ProgressView().tint(.white)
                        }
                        // Use OrderViewModel's loading state for text
                        // Calculate total based on cart or single product
                        Text(orderViewModel.isPlacingOrder ? "Placing Order..." : "Place Order - \(String(format: "$%.2f", calculateFinalTotal()))")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 30)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom, 8)
                .background(.regularMaterial)
                // Disable button based on cart content (if cart mode) OR OrderViewModel's loading state
                .disabled(shouldDisablePlaceOrderButton())
            }
        }
        // Optional: Reset placement state when view disappears to allow re-entry
        .onDisappear {
            orderViewModel.orderPlacedSuccessfully = false
            orderViewModel.placementErrorMessage = nil
            // Don't reset isPlacingOrder here, let the Task finish
        }
    }
    
    // Helper function to calculate total based on context
    private func calculateFinalTotal() -> Double {
        let basePrice: Double
        if let product = singleProduct {
            basePrice = product.price // Assuming quantity 1 for single item
        } else {
            basePrice = cartViewModel.totalPrice // Use cart total
        }
        // Add consistent shipping/tax calculation
        let shippingCost: Double = 5.00 // Example
        let taxAmount: Double = basePrice * 0.08 // Example 8% tax
        return basePrice + shippingCost + taxAmount
    }
    
    // Helper for disabling the button logic
    private func shouldDisablePlaceOrderButton() -> Bool {
        if orderViewModel.isPlacingOrder { return true } // Always disable if placing
        if singleProduct != nil {
            // Logic for single product - maybe check stock if available?
            return false // Allow placing single product for now
        } else {
            // Logic for cart
            return cartViewModel.cartItems.isEmpty // Disable if cart is empty
        }
    }
}

// --- Placeholder Confirmation View ---
struct OrderConfirmationView: View {
    let order: Order
    @Environment(\.dismiss) var dismiss // To potentially dismiss checkout view
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            Text("Order Placed!")
                .font(.largeTitle)
                .padding(.top)
            Text("Your order #\(order.orderNumber) has been confirmed.")
                .foregroundColor(.secondary)
                .padding(.bottom)
            // Optionally show summary or link to order details
            NavigationLink("View Order Details") {
                OrderDetailView(order: order)
            }
            Spacer()
            Button("Done") {
                print("Order placed")
                dismiss()
//                appViewModel.shouldPopToRoot = true
//                print("Done tapped - need better navigation handling")
            }
            .padding(.bottom)
        }
        .navigationTitle("Confirmation")
        .navigationBarBackButtonHidden() // Hide back button after confirmation
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
