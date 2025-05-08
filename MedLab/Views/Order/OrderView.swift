//
//  ClassifyView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 30/3/25.
//

import SwiftUI

//struct OrderView: View {
//    // *** CHANGE THIS: Use @EnvironmentObject to get the SHARED instance ***
//    @EnvironmentObject var orderViewModel: OrderViewModel
//    // *** REMOVE: @StateObject private var orderViewModel = OrderViewModel() ***
//
//    var body: some View {
//        // Use NavigationStack for modern navigation
//        NavigationStack {
//            ZStack { // Use ZStack for overlaying ProgressView
//                // Main List Content
//                List {
//                    // Check if orders are loaded and not empty (Using the SHARED orderViewModel)
//                    if !orderViewModel.isLoadingList && !orderViewModel.orders.isEmpty { // Use isLoadingList
//                        ForEach(orderViewModel.orders) { order in
//                            NavigationLink {
//                                // Destination: Detail view for the selected order
//                                OrderDetailView(order: order)
//                            } label: {
//                                // Row View: How each order looks in the list
//                                OrderRow(order: order)
//                            }
//                        }
//                    }
//                    // ... (rest of List remains the same) ...
//                }
//                .listStyle(.plain)
//                .refreshable {
//                    // Call loadOrders on the SHARED orderViewModel
//                    await orderViewModel.loadOrders()
//                }
//
//                // --- Overlays for Loading/Empty/Error States (Using the SHARED orderViewModel) ---
//                if orderViewModel.isLoadingList && orderViewModel.orders.isEmpty { // Use isLoadingList
//                    ProgressView()
//                        .scaleEffect(1.5)
//                        .progressViewStyle(.circular)
//                } else if !orderViewModel.isLoadingList && orderViewModel.orders.isEmpty { // Use isLoadingList
//                     // Empty State View
//                    VStack(spacing: 10) { /* ... Empty state content ... */ }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .background(Color(.systemBackground))
//                } else if let errorMessage = orderViewModel.listErrorMessage { // Use listErrorMessage
//                    // Error State View
//                     VStack(spacing: 10) {
//                         // ... Error state content ...
//                         Button("Retry") {
//                             // Call loadOrders on the SHARED orderViewModel
//                             Task { await orderViewModel.loadOrders() }
//                         }
//                         // ...
//                     }
//                     .frame(maxWidth: .infinity, maxHeight: .infinity)
//                     .background(Color(.systemBackground))
//                 }
//
//            } // End ZStack
//            .navigationTitle("My Orders")
//            .onAppear {
//                // Load orders using the SHARED orderViewModel if empty
//                // This ensures data is loaded when the tab becomes active if needed
//                if orderViewModel.orders.isEmpty && !orderViewModel.isLoadingList { // Check loading flag too
//                    Task {
//                        await orderViewModel.loadOrders()
//                    }
//                }
//            }
//        } // End NavigationStack
//    }
//}

struct OrderView: View {
    // Create and own the orderViewModel for this view's lifecycle
    @EnvironmentObject private var orderViewModel: OrderViewModel

    var body: some View {
        // Use NavigationStack for modern navigation
        NavigationStack {
            ZStack { // Use ZStack for overlaying ProgressView
                // Main List Content
                List {
                    // Check if orders are loaded and not empty
                    if !orderViewModel.isLoading && !orderViewModel.orders.isEmpty {
                        ForEach(orderViewModel.orders) { order in
                            NavigationLink {
                                // Destination: Detail view for the selected order
                                OrderDetailView(order: order)
                            } label: {
                                // Row View: How each order looks in the list
                                OrderRow(order: order)
                            }
                        }
                    }
                    // Do not show empty/error message inside the List if it's loading
                    // Handle those states outside the list using the ZStack overlay
                }
                .listStyle(.plain) // Optional: Use plain style
                // Pull-to-refresh functionality
                .refreshable {
                    await orderViewModel.loadOrders()
                }

                // --- Overlays for Loading/Empty/Error States ---
                if orderViewModel.isLoading && orderViewModel.orders.isEmpty {
                    // Show loading indicator only on initial load
                    ProgressView()
                        .scaleEffect(1.5) // Make it slightly larger
                        .progressViewStyle(.circular)
                } else if !orderViewModel.isLoading && orderViewModel.orders.isEmpty {
                     // Empty State View
                    VStack(spacing: 10) {
                        Image(systemName: "shippingbox") // Or relevant icon
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("No Orders Yet")
                            .font(.title2)
                        Text("Your past orders will appear here.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    // Prevent List separators from showing through
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground)) // Match list background
                } else if let errorMessage = orderViewModel.errorMessage {
                    // Error State View
                     VStack(spacing: 10) {
                         Image(systemName: "exclamationmark.triangle")
                             .font(.system(size: 50))
                             .foregroundColor(.red)
                         Text("Error Loading Orders")
                             .font(.title2)
                         Text(errorMessage)
                             .font(.subheadline)
                             .foregroundColor(.secondary)
                             .multilineTextAlignment(.center)
                             .padding(.horizontal)
                         Button("Retry") {
                             Task { await orderViewModel.loadOrders() }
                         }
                         .buttonStyle(.bordered)
                         .padding(.top)
                     }
                     .frame(maxWidth: .infinity, maxHeight: .infinity)
                     .background(Color(.systemBackground))
                 }

            } // End ZStack
            .navigationTitle("My Orders")
            // Load orders when the view appears
            .onAppear {
                // Only load initially if orders haven't been loaded yet
                if orderViewModel.orders.isEmpty {
                    Task {
                        await orderViewModel.loadOrders()
                    }
                }
            }
        } // End NavigationStack
    }
}

// MARK: - Order Row Subview

struct OrderRow: View {
    let order: Order

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Order #\(order.orderNumber)")
                    .font(.headline)
                Text(order.createdAt, style: .date) // Format date only
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 5) {
                Text(order.totalAmount, format: .currency(code: "USD")) // Format as currency
                    .font(.headline)
                OrderStatusBadge(status: order.status) // Use a dedicated badge view
            }
        }
        .padding(.vertical, 8) // Add padding inside the row
    }
}

// MARK: - Order Status Badge Subview

struct OrderStatusBadge: View {
    let status: OrderStatus

    var body: some View {
        Text(status.rawValue)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundColor(statusTextColor) // Dynamic text color
            .background(statusBackgroundColor) // Dynamic background
            .cornerRadius(10)
    }

    // Determine colors based on status
    private var statusBackgroundColor: Color {
        switch status {
        case .pending, .processing: return .orange.opacity(0.2)
        case .shipped: return .blue.opacity(0.2)
        case .delivered: return .green.opacity(0.2)
        case .cancelled, .refunded: return .gray.opacity(0.2)
        }
    }

     private var statusTextColor: Color {
        switch status {
        case .pending, .processing: return .orange
        case .shipped: return .blue
        case .delivered: return .green
        case .cancelled, .refunded: return .secondary
        }
    }
}

//////////////

struct OrderDetailView: View {
    let order: Order // Passed in when navigating

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Order Header Info
                VStack(alignment: .leading, spacing: 5) {
                    Text("Order #\(order.orderNumber)")
                        .font(.title.weight(.bold))
                    HStack {
                        Text("Placed on \(order.createdAt, style: .date)")
                        Spacer()
                        OrderStatusBadge(status: order.status)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    if let tracking = order.trackingNumber, statusRequiresTracking(order.status) {
                         Link("Track Package: \(tracking)", destination: URL(string: "your_tracking_url_prefix/\(tracking)")!) // Replace with actual URL logic
                             .font(.subheadline)
                             .padding(.top, 2)
                     }
                }
                .padding(.bottom)

                Divider()

                // Items Section
                VStack(alignment: .leading) {
                    Text("Items (\(order.items.count))")
                        .font(.title3.weight(.semibold))
                        .padding(.bottom, 5)

                    // Use ForEach inside VStack as List inside ScrollView can cause issues
                    ForEach(order.items) { item in
                        OrderItemRow(item: item)
                        Divider() // Separator between items
                    }
                }

                 Divider()

                // Shipping Address Section
                VStack(alignment: .leading) {
                     Text("Shipping Address")
                         .font(.title3.weight(.semibold))
                     ShippingAddressView(address: order.shippingAddress) // Reusable address view
                 }
                 .padding(.top)

                 Divider()

                // Payment Method Section
                 VStack(alignment: .leading) {
                     Text("Payment Method")
                         .font(.title3.weight(.semibold))
                     Text(order.paymentMethodDetails ?? "N/A")
                         .font(.subheadline)
                         .foregroundColor(.secondary)
                 }
                 .padding(.top)

                Divider()

                // Order Totals Section
                 OrderTotalsView(order: order)
                 .padding(.top)


            } // End Main VStack
            .padding() // Padding for the whole scroll content
        } // End ScrollView
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
    }

     // Helper to decide if tracking link should show
     private func statusRequiresTracking(_ status: OrderStatus) -> Bool {
         switch status {
         case .shipped, .delivered: return true
         default: return false
         }
     }
}

// MARK: - Order Detail Subviews

struct OrderItemRow: View {
    let item: OrderItem

    var body: some View {
        HStack(spacing: 15) {
            AsyncImage(url: URL(string: item.imageUrlSnapshot ?? "")) { phase in
                 // ... AsyncImage handling (same as CartItemRow) ...
                 switch phase {
                 case .success(let image):
                     image.resizable().aspectRatio(contentMode: .fit)
                 case .failure(_):
                     Image(systemName: "photo").foregroundColor(.secondary)
                 case .empty:
                     ProgressView()
                 @unknown default:
                     EmptyView()
                 }
            }
            .frame(width: 50, height: 50)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(5)

            VStack(alignment: .leading) {
                Text(item.productNameSnapshot)
                    .font(.body)
                Text("Qty: \(item.quantity)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                 Text(item.subtotal, format: .currency(code: "USD"))
                    .font(.body.weight(.medium))
                 Text(item.priceAtPurchase, format: .currency(code: "USD"))
                    .font(.caption)
                    .foregroundColor(.secondary)
             }
        }
        .padding(.vertical, 5)
    }
}

struct ShippingAddressView: View {
    let address: ShippingAddress

    var body: some View {
        VStack(alignment: .leading) {
            if let name = address.recipientName { Text(name) }
            Text(address.street)
            Text("\(address.city), \(address.state) \(address.postalCode)")
            Text(address.country)
            if let phone = address.phoneNumber { Text(phone) }
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
    }
}

struct OrderTotalsView: View {
     let order: Order

     var body: some View {
          VStack(spacing: 5) {
               HStack { Text("Subtotal"); Spacer(); Text(order.items.reduce(0){$0 + $1.subtotal}, format: .currency(code: "USD")) }
               HStack { Text("Shipping"); Spacer(); Text(order.shippingCost, format: .currency(code: "USD")) }
               HStack { Text("Tax"); Spacer(); Text(order.taxAmount, format: .currency(code: "USD")) }
               Divider().padding(.vertical, 4)
               HStack { Text("Total").bold(); Spacer(); Text(order.totalAmount, format: .currency(code: "USD")).bold() }
          }
          .font(.subheadline)
     }
 }
