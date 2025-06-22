//
//  OrderViewModel.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 23/4/25.
//

import SwiftUI
import Combine

//// Placeholder Service for fetching orders (Replace with your actual API call)
//protocol OrderFetching {
//    func fetchUserOrders() async throws -> [Order]
//}
//
//class MockOrderService: OrderFetching, ObservableObject {
//    func fetchUserOrders() async throws -> [Order] {
//        // Simulate network delay
//        try await Task.sleep(nanoseconds: 1_500_000_000)
//        // Return sample data or an empty array to test states
//        // return [] // Test empty state
//         return Order.sampleOrders // Use dummy data
//        // throw ApiClientError.networkError(URLError(.notConnectedToInternet)) // Test error state
//    }
//}

@MainActor
class OrderViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // Properties for placing order
    @Published var isPlacingOrder: Bool = false // Loading state specific to placing order
    @Published var placementErrorMessage: String? = nil
    @Published var orderPlacedSuccessfully: Bool = false
    @Published var newlyPlacedOrder: Order? = nil

    private let orderService: OrderServicing // Dependency
    private let appViewModel: AppViewModel
    private let cartViewModel: CartViewModel

    init(orderService: OrderServicing, cartViewModel: CartViewModel, appViewModel: AppViewModel) {
        self.orderService = orderService
        self.cartViewModel = cartViewModel
        self.appViewModel = appViewModel
    }

    func loadOrders() async {
        // Prevent multiple loads if already loading
        guard !isLoading else { return }

        print("OrderViewModel: Fetching orders...")
        isLoading = true
        errorMessage = nil // Clear previous errors
        orderPlacedSuccessfully = false // reset property

        do {
            // Fetch orders using the injected service
            let fetchedOrders = try await orderService.fetchUserOrder()
            self.orders = fetchedOrders.sorted { $0.createdAt > $1.createdAt } // Sort newest first
            print("OrderViewModel: Fetched \(self.orders.count) orders.")
        } catch let error as ApiClientError { // Catch specific API errors if defined
             print("❌ OrderViewModel: API Error fetching orders: \(error)")
             self.errorMessage = "Failed to load orders. Please check your connection." // User-friendly message
        } catch {
            print("❌ OrderViewModel: Unexpected error fetching orders: \(error)")
            self.errorMessage = "An unexpected error occurred."
        }

        isLoading = false
    }
    
    func placeOrder(
        shippingAddress: ShippingAddress,
        paymentDetails: String?,
        selectedVoucher: Voucher? = nil
    ) async {
        guard !isPlacingOrder else {
            print("OrderViewModel: Already placing order.")
            return
        }
        
        guard (appViewModel.user?.id) != nil else {
            self.placementErrorMessage = "User not authenticated. Cannot place order."
            print("❌ \(self.placementErrorMessage!)")
            return
        }
        
        guard appViewModel.user?.address != nil else {
            self.placementErrorMessage = "Please set your address before placing an order."
            print("❌ \(self.placementErrorMessage!)")
            return
        }
        
        guard !cartViewModel.cartItems.isEmpty else {
            self.placementErrorMessage = "Your cart is empty. Cannot place order."
            print("❌ \(self.placementErrorMessage!)")
            return
        }
        
        print("OrderViewModel: Starting order placement...")
        isPlacingOrder = true // Set placing order state
        placementErrorMessage = nil
        orderPlacedSuccessfully = false
        newlyPlacedOrder = nil // Clear any previously placed order info
        
        // 1. Prepare the data needed for the API request body
        let itemsForRequest: [CreateOrderItemRequest] = cartViewModel.cartItems.map { cartItem in
            CreateOrderItemRequest(productId: cartItem.product.id, quantity: cartItem.quantity)
        }
        
        print(itemsForRequest)
        
        do {
            // 2. Call the injected OrderService to place the order via API
            print("OrderViewModel: Calling orderService.placeOrder...")
            let createOrderResponse = try await orderService.placeOrder( // Use the injected service
                items: itemsForRequest,
                shippingAddress: shippingAddress,
                paymentDetails: paymentDetails,
                discountPercentage: Double(selectedVoucher?.discount ?? 0)
            )
            
            // --- SUCCESS ---
            let finalizedOrder = createOrderResponse.order // Get the final order from response
            print("OrderViewModel: Order placed successfully on backend. Order #: \(finalizedOrder.orderNumber)")
            
            
            
            
            // 3. Update Local State on Success
            self.newlyPlacedOrder = finalizedOrder // Store the new order if needed
            self.orders.insert(finalizedOrder, at: 0) // Add to the beginning of the local orders list
            self.cartViewModel.clearLocalCartData() // Clear the cart in the CartViewModel
            self.orderPlacedSuccessfully = true // Set flag for UI navigation/updates
            
            guard let usedVoucher = selectedVoucher else {
                return
            }
            
            let redeemVoucherResponse = try await orderService.redeemVoucher(code: usedVoucher.code)
            appViewModel.user?.usedVouchersCode.append(usedVoucher.code)
//            appViewModel.user?.usedVouchersCode = (appViewModel.user?.usedVouchersCode ?? []) + [code]

        } catch let error as ApiClientError {
            // Handle specific API client errors
            print("❌ OrderViewModel: API Error placing order: \(error)")
            switch error {
            case .authenticationError:
                self.placementErrorMessage = "Authentication failed. Please log in again."
            case .requestFailed(let statusCode, _):
                // Check for specific status codes like 400 (Bad Request - e.g., stock issue)
                if statusCode == 400 {
                    // You might want to parse the response data here if the API provides details
                    // about which item caused the failure (e.g., insufficient stock)
                    self.placementErrorMessage = "Failed to place order. Please check cart items (e.g., stock)."
                } else {
                    self.placementErrorMessage = "Failed to place order. Server error (\(statusCode))."
                }
            case .networkError(let urlError):
                self.placementErrorMessage = "Network error. Please check connection (\(urlError.localizedDescription))."
            case .decodingError, .encodingError:
                self.placementErrorMessage = "Failed to process order data. Please try again."
            default:
                self.placementErrorMessage = "An unknown error occurred while placing the order."
            }
        } catch {
            // Handle other unexpected errors
            print("❌ OrderViewModel: Unexpected error placing order: \(error)")
            self.placementErrorMessage = "An unexpected error occurred."
        }
        
        // 4. Reset loading state regardless of outcome
        isPlacingOrder = false
        print("OrderViewModel: Order placement finished.")
    }
    
    func clearLocalOrders() {
        print("OrderViewModel: Clearing local orders.")
        self.orders = []
    }
}
