//
//  CartService.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 22/4/25.
//

import Foundation

struct PopulatedProductDetails: Codable, Identifiable {
    let id: String
    let name: String
    let price: Double
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case price
        case imageUrl
    }
}

struct CartItemResponse: Codable {
    let productId: PopulatedProductDetails
    let quantity: Int
}

struct CartResponse: Codable {
    let id: String?
    let userId: String?
    let items: [CartItemResponse]
    let createdAt: String
    let updatedAt: String


     enum CodingKeys: String, CodingKey {
         case id = "_id"
         case userId
         case items
         case createdAt
         case updatedAt
     }
}

struct AddCartItemRequest: Encodable {
    let productId: String
    let quantity: Int
}

struct UpdateCartItemRequest: Encodable {
    let quantity: Int
}

protocol CartServicing {
    func getCart() async throws -> CartResponse
    func addItem(productId: String, quantity: Int) async throws -> CartResponse
    func updateItemQuantity(productId: String, quantity: Int) async throws -> CartResponse
    func removeItem(productId: String) async throws -> CartResponse
    func clearCart() async throws
}

class CartService: CartServicing, ObservableObject {
    private let apiClient: ApiClient
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    func getCart() async throws -> CartResponse {
        print("CartService: Fetching cart...")
        return try await apiClient.request(
            endpoint: .getCart,
            body: Optional<EmptyBody>.none,
            responseType: CartResponse.self
        )
    }
    
    func addItem(productId: String, quantity: Int) async throws -> CartResponse {
        print("CartService: Adding/updating item - Product ID: \(productId), Quantity: \(quantity)")
        let requestBody = AddCartItemRequest(productId: productId, quantity: quantity)
        
        return try await apiClient.request(
            endpoint: .addCartItem(productId: productId, quantity: quantity),
            body: requestBody,
            responseType: CartResponse.self
        )
    }
    
    func updateItemQuantity(productId: String, quantity: Int) async throws -> CartResponse {
        print("CartService: Setting item quantity - Product ID: \(productId), Quantity: \(quantity)")
        let requestBody = UpdateCartItemRequest(quantity: quantity)
        
        return try await apiClient.request(
            endpoint: .updateCartItemQuantity(productId: productId, quantity: quantity),
            body: requestBody,
            responseType: CartResponse.self
        )
    }
    
    func removeItem(productId: String) async throws -> CartResponse {
        print("CartService: Removing item - Product ID: \(productId)")
        return try await apiClient.request(
            endpoint: .removeCartItem(productId: productId),
            body: Optional<EmptyBody>.none,
            responseType: CartResponse.self
        )
    }
    
    func clearCart() async throws {
        print("CartService: Clearing cart...")
        _ = try await apiClient.request(
            endpoint: .clearCart,
            body: Optional<EmptyBody>.none,
            responseType: EmptyResponse.self
        )
    }
}
