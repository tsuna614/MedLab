//
//  CartView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 18/4/25.
//

import SwiftUI

struct CartView: View {
    // Access the shared CartViewModel from the environment
    @EnvironmentObject var cartViewModel: CartViewModel
    // inject appVM and navigationPath to pop the checkout view when pressing "Done"
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack { // Use VStack to allow adding summary/buttons outside the List
                if cartViewModel.cartItems.isEmpty {
                    // --- Empty Cart State ---
                    VStack {
                        Spacer()
                        Image(systemName: "cart.badge.questionmark") // Example icon
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("Your Cart is Empty")
                            .font(.title2)
                            .padding(.top)
                        Text("Add some products to get started!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Spacer() // Extra spacer for balance
                    }
                } else {
                    // --- Cart Items List ---
                    List {
                        ForEach(cartViewModel.cartItems) { item in
                            CartItemRow(item: item)
                                .id("\(item.product.id) - \(item.quantity)")
                        }
                        .onDelete(perform: deleteItems) // Enable swipe to delete
                    }
                    .listStyle(.plain) // Optional: Removes default inset grouped styling
                    
                    // --- Summary Section ---
                    CartSummaryView()
                        .padding() // Add padding around the summary box
                }
            }
            .navigationTitle("Shopping Cart")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .onChange(of: appViewModel.shouldPopToRoot) { oldValue, newValue in
                print("popping view")
                if newValue == true {
                    print("Popping navigation stack to root (New onChange)...")
                    Task { @MainActor in
                        if appViewModel.shouldPopToRoot == true {
                            navigationPath = NavigationPath() // Reset path HERE
                            appViewModel.shouldPopToRoot = false // Reset flag
                            print("Reset path and shouldPopToRoot flag.")
                        }
                    }
                }
            }
        }
        // Inject the ViewModel for the preview if needed directly here
        // .environmentObject(CartViewModel(sampleData: true))
    }
    
    // Function to handle swipe-to-delete
    private func deleteItems(at offsets: IndexSet) {
        // Get the products corresponding to the offsets based on the current items array
        let itemToDelete = offsets.map { cartViewModel.cartItems[$0] }
        // Call the ViewModel's remove method for each identified product
        itemToDelete.forEach { item in
            Task {
                await cartViewModel.removeItem(productId: item.product.id)
            }
        }
    }
}

// MARK: - Subviews for CartView

struct CartItemRow: View {
    let item: CartItem
    @EnvironmentObject var cartViewModel: CartViewModel // Needs access to modify
    
    // FOR SOME REASON item.quantity is changing but the view isn't updating, so we do this
    private var currentQuantity: Int {
        cartViewModel.cartItems.first { $0.product.id == item.product.id }?.quantity ?? 0
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Product Image (Using AsyncImage for URLs)
            AsyncImage(url: URL(string: item.product.imageUrl ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure(_):
                    Image(systemName: "photo") // Placeholder on failure
                        .foregroundColor(.secondary)
                case .empty:
                    ProgressView() // Loading indicator
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 60, height: 60)
            .background(Color.gray.opacity(0.1)) // Subtle background
            .cornerRadius(8)
            
            // Product Details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.name)
                    .font(.headline)
                    .lineLimit(2) // Allow up to two lines for name
                
                Text(String(format: "$%.2f", item.product.price)) // Price per unit
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Quantity Controls
                HStack {
                    Button {
                        Task {
                            await cartViewModel.decreaseQuantity(for: item.product)
                        }
                    } label: {
                        Image(systemName: "minus.circle")
                            .foregroundColor(currentQuantity > 1 ? .blue : .gray) // Indicate disabled state
                    }
                    .disabled(currentQuantity <= 1)
                    
                    Text("\(currentQuantity)")
                        .font(.body.weight(.medium))
                        .frame(minWidth: 25, alignment: .center) // Ensure space
                    
                    Button {
                        Task {
                            await cartViewModel.increaseQuantity(for: item.product)
                            
                        }
                    } label: {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.blue)
                    }
                }
                .buttonStyle(.plain) // Important for List row buttons
                .padding(.top, 5)
            }
            
            Spacer() // Pushes total price to the right
            
            // Total Price for this item * quantity
            Text(String(format: "$%.2f", item.totalPrice))
                .font(.headline)
        }
        .padding(.vertical, 8) // Add some vertical padding to rows
    }
}


struct CartSummaryView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Order Summary")
                .font(.title3.weight(.semibold))
            
            Divider()
            
            HStack {
                Text("Subtotal (\(cartViewModel.totalQuantity) items)")
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "$%.2f", cartViewModel.totalPrice))
                    .font(.body.weight(.medium))
            }
            
            Divider()
            
            HStack {
                Text("Total")
                    .font(.headline)
                Spacer()
                Text(String(format: "$%.2f", cartViewModel.totalPrice)) // Update if you add tax/shipping
                    .font(.headline)
            }
            
            NavigationLink {
                CheckoutView()
            } label: {
                Text("Proceed to Checkout")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            // Disable the link if the cart is empty
            .disabled(cartViewModel.cartItems.isEmpty)
            .padding(.top)
            
        }
        .padding()
        .background(Color(.systemGray6)) // Subtle background for the box
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
    }
}
