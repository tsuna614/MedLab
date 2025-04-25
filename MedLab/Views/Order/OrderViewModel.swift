//
//  OrderViewModel.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 23/4/25.
//

import SwiftUI
import Combine

// Placeholder Service for fetching orders (Replace with your actual API call)
protocol OrderFetching {
    func fetchUserOrders() async throws -> [Order]
}

class MockOrderService: OrderFetching {
    func fetchUserOrders() async throws -> [Order] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000)
        // Return sample data or an empty array to test states
        // return [] // Test empty state
         return Order.sampleOrders // Use dummy data
        // throw ApiClientError.networkError(URLError(.notConnectedToInternet)) // Test error state
    }
}


@MainActor
class OrderViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let orderFetcher: OrderFetching // Dependency

    // Inject the service
    init(orderFetcher: OrderFetching = MockOrderService()) { // Use mock by default for easy preview/init
        self.orderFetcher = orderFetcher
    }

    func loadOrders() async {
        // Prevent multiple loads if already loading
        guard !isLoading else { return }

        print("OrderViewModel: Fetching orders...")
        isLoading = true
        errorMessage = nil // Clear previous errors

        do {
            // Fetch orders using the injected service
            let fetchedOrders = try await orderFetcher.fetchUserOrders()
            self.orders = fetchedOrders.sorted { $0.orderDate > $1.orderDate } // Sort newest first
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
}
