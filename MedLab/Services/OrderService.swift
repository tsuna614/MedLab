//
//  OrderService.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 26/4/25.
//

import Foundation

struct CreateOrderItemRequest: Encodable {
    let productId: String
    let quantity: Int
}

struct CreateOrderRequest: Encodable {
    let items: [CreateOrderItemRequest]
    let shippingAddress: ShippingAddress
    let paymentMethodDetails: String?
}

struct CreateOrderResponse: Codable {
    let message: String
    let order: Order
}

protocol OrderServicing {
//    func getCart() async throws -> CartResponse
//    func addItem(productId: String, quantity: Int) async throws -> CartResponse
//    func updateItemQuantity(productId: String, quantity: Int) async throws -> CartResponse
//    func removeItem(productId: String) async throws -> CartResponse
//    func clearCart() async throws
    func placeOrder(items: [CreateOrderItemRequest], shippingAddress: ShippingAddress, paymentDetails: String?) async throws -> CreateOrderResponse
    func fetchUserOrder() async throws -> [Order]
}

class OrderService: OrderServicing, ObservableObject {
    private let apiClient: ApiClient
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    func placeOrder(items: [CreateOrderItemRequest], shippingAddress: ShippingAddress, paymentDetails: String?) async throws -> CreateOrderResponse {
        let requestBody = CreateOrderRequest(
            items: items,
            shippingAddress: shippingAddress,
            paymentMethodDetails: paymentDetails
        )
        
        return try await apiClient.request(
            endpoint: .createOrder(orderData: requestBody),
            body: requestBody,
            responseType: CreateOrderResponse.self
        )
    }
    
    func fetchUserOrder() async throws -> [Order] {
        return try await apiClient.request(
            endpoint: .getOrders,
            body: Optional<EmptyBody>.none,
            responseType: [Order].self
        )
    }
}
