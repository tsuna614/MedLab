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
    
    @ObservedObject var voucherViewModel: VoucherViewModel
    
    let singleProduct: Product?
    
    @State private var shippingRecipient: String = "Jane Doe" // Example state for form
    @State private var shippingStreet: String = "123 Main St"
    @State private var shippingCity: String = "Anytown"
    @State private var shippingState: String = "CA"
    @State private var shippingPostalCode: String = "12345"
    @State private var shippingCountry: String = "USA"
    @State private var paymentInfo: String? = "Visa ending in 4242" // Example
    
    @State private var navigateToOrderConfirmation: Bool = false
    
    init(singleProduct: Product? = nil) {
        self.singleProduct = singleProduct
        print("CheckoutView initialized for product: \(singleProduct?.name ?? "Cart")")
        
        let voucherServiceInstance = VoucherService(apiClient: ApiClient(baseURLString: base_url))
//        _voucherViewModel = StateObject(wrappedValue: VoucherViewModel(voucherService: voucherServiceInstance))
        _voucherViewModel = ObservedObject(wrappedValue: VoucherViewModel(voucherService: voucherServiceInstance))
    }
    
    
    var body: some View {
        let _ = Self._printChanges()
        
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    SectionBox {
                        VStack(alignment: .leading){
                            Text("Shipping Address").font(.title3.weight(.semibold))
                            // TODO: Replace Text with actual TextField/Form elements bound to @State vars
                            Text("\(shippingRecipient)\n\(shippingStreet)\n\(shippingCity), \(shippingState) \(shippingPostalCode)\n\(shippingCountry)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    SectionBox {
                        VStack(alignment: .leading){
                            Text("Payment Method").font(.title3.weight(.semibold))
                            // TODO: Replace Text with actual payment selection UI
                            Text(paymentInfo ?? "N/A")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Order Summary")
                                .font(.title3.weight(.semibold))
                                .padding(.horizontal)
                            
                            NavigationLink(destination: VoucherView(voucherVM: voucherViewModel)) {
                                Text("Add vouchers")
                            }
                        }
                        
                        if let product = singleProduct {
                            SingleProductCheckoutSummaryView(singleProduct: product)
                        } else {
                            CheckoutSummaryView(voucherViewModel: voucherViewModel)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical)
                .alert("Order Error", isPresented: .constant(orderViewModel.placementErrorMessage != nil), actions: {
                    Button("OK") { orderViewModel.placementErrorMessage = nil } // Clear error
                }) {
                    Text(orderViewModel.placementErrorMessage ?? "An unknown error occurred.")
                }
                
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $navigateToOrderConfirmation) {
                if let order = orderViewModel.newlyPlacedOrder {
                    OrderConfirmationView(order: order)
                } else {
                    Text("Order Confirmed (Details Pending)") // Fallback
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    if singleProduct != nil {
                        print("WARN: Placing single product order not fully implemented in ViewModel yet.")
                        orderViewModel.placementErrorMessage = "Buy Now -> Place Order not implemented."
                        return
                    }
                    
                    let currentShippingAddress = ShippingAddress(
                        recipientName: shippingRecipient, street: shippingStreet, city: shippingCity,
                        state: shippingState, postalCode: shippingPostalCode, country: shippingCountry, phoneNumber: nil
                    )
                    Task {
                        await orderViewModel.placeOrder(
                            shippingAddress: currentShippingAddress,
                            paymentDetails: paymentInfo,
                            selectedVoucher: voucherViewModel.selectedVoucher
                        )
                        if orderViewModel.orderPlacedSuccessfully {
                            navigateToOrderConfirmation = true
                        }
                    }
                } label: {
                    HStack {
                        if orderViewModel.isPlacingOrder {
                            ProgressView().tint(.white)
                        }
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
                .disabled(shouldDisablePlaceOrderButton())
            }
        }
        .onDisappear {
            orderViewModel.orderPlacedSuccessfully = false
            orderViewModel.placementErrorMessage = nil
        }
    }
    
    private func calculateFinalTotal() -> Double {
        let basePrice: Double
        if let product = singleProduct {
            basePrice = product.price // Assuming quantity 1 for single item
        } else {
            basePrice = cartViewModel.totalPrice // Use cart total
        }
        let shippingCost: Double = 5.00 // Example
        let taxAmount: Double = basePrice * 0.08 // Example 8% tax
        return (basePrice + shippingCost + taxAmount) * voucherViewModel.discountMultiplier
    }
    
    private func shouldDisablePlaceOrderButton() -> Bool {
        if orderViewModel.isPlacingOrder { return true } // Always disable if placing
        if singleProduct != nil {
            return false // Allow placing single product for now
        } else {
            return cartViewModel.cartItems.isEmpty // Disable if cart is empty
        }
    }
}

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
            NavigationLink("View Order Details") {
                OrderDetailView(order: order)
            }
            Spacer()
            Button("Done") {
                print("Order placed")
                dismiss()
            }
            .padding(.bottom)
        }
        .navigationTitle("Confirmation")
        .navigationBarBackButtonHidden() // Hide back button after confirmation
    }
}

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

struct CheckoutSummaryView: View {
    @StateObject var voucherViewModel: VoucherViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    
    let shippingCost: Double = 5.00
    var taxAmount: Double { cartViewModel.totalPrice * 0.08 } // 8% tax
    var discountPercentage: Int { voucherViewModel.selectedVoucher?.discount ?? 0 }
    var total: Double {
        (cartViewModel.totalPrice + shippingCost + taxAmount) * voucherViewModel.discountMultiplier
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            Divider()
            
            HStack {
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
            HStack {
                Text("Discount Percentage")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(discountPercentage)%")
                    .font(.body.weight(.medium))
            }
            
            if voucherViewModel.selectedVoucher != nil {
                Divider()
                
                HStack {
                    Text("Voucher Applied")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(voucherViewModel.selectedVoucher!.code)
                        .font(.body.weight(.medium))
                }
                
                HStack {
                    Spacer()
                    
                    Button {
                        voucherViewModel.clearSelectedVoucher()
                    } label: {
                        Text("Remove")
                    }
                }
            }
            
            
            Divider()
            
            HStack {
                Text("Total")
                    .font(.headline)
                Spacer()
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

struct SingleProductCheckoutSummaryView: View {
    var singleProduct: Product

    let shippingCost: Double = 5.00
    var taxAmount: Double { singleProduct.price * 0.08 } // 8% tax
    var total: Double { singleProduct.price + shippingCost + taxAmount }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Divider()
            
            HStack {
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
