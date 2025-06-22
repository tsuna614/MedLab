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
    let discountPercentage: Double?
}

struct CreateOrderResponse: Codable {
    let message: String
    let order: Order
}

struct RedeemVoucherRequest: Codable {
    let voucherCode: String
}

struct RedeemVoucherResponse: Codable {
    let message: String
}

protocol OrderServicing {
//    func getCart() async throws -> CartResponse
//    func addItem(productId: String, quantity: Int) async throws -> CartResponse
//    func updateItemQuantity(productId: String, quantity: Int) async throws -> CartResponse
//    func removeItem(productId: String) async throws -> CartResponse
//    func clearCart() async throws
    func placeOrder(items: [CreateOrderItemRequest], shippingAddress: ShippingAddress, paymentDetails: String?, discountPercentage: Double?) async throws -> CreateOrderResponse
    func fetchUserOrder() async throws -> [Order]
    func redeemVoucher(code: String) async throws -> RedeemVoucherResponse
}

class OrderService: OrderServicing, ObservableObject {
    private let apiClient: ApiClient
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    func placeOrder(items: [CreateOrderItemRequest], shippingAddress: ShippingAddress, paymentDetails: String?, discountPercentage: Double?) async throws -> CreateOrderResponse {
        let requestBody = CreateOrderRequest(
            items: items,
            shippingAddress: shippingAddress,
            paymentMethodDetails: paymentDetails,
            discountPercentage: discountPercentage
        )
        
        return try await apiClient.request(
            endpoint: .createOrder,
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
    
    func redeemVoucher(code: String) async throws -> RedeemVoucherResponse {
        let requestBody = RedeemVoucherRequest(voucherCode: code)
        
        return try await apiClient.request(
            endpoint: .redeemVoucher,
            body: requestBody,
            responseType: RedeemVoucherResponse.self
        )
    }
}
