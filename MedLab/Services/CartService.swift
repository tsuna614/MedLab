//
//  CartService.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 22/4/25.
//

import Foundation

// 1. Define the structure for the POPULATED product data inside the cart item
struct PopulatedProductDetails: Codable, Identifiable { // Make it Identifiable
    let id: String // The product's ID
    let name: String
    let price: Double
    let imageUrl: String?
    // Add ANY OTHER product fields your .populate() call returns
    // (e.g., brand, category...)

    // Map backend keys (like _id) if necessary
    enum CodingKeys: String, CodingKey {
        case id = "_id" // Map backend "_id" to Swift "id" if needed
        case name
        case price
        case imageUrl
        // Map other fields if backend keys differ
    }
}

// 2. Update CartItemResponse to expect the POPULATED product object
struct CartItemResponse: Codable {
    // This should now match the OBJECT returned by populate, not just the ID string
    let productId: PopulatedProductDetails // <-- CRITICAL CHANGE
    let quantity: Int

    // Adjust CodingKeys if the key name in JSON is different (e.g., "product")
    // enum CodingKeys: String, CodingKey {
    //     case productId = "product" // If JSON key is "product" instead of "productId"
    //     case quantity
    // }
}

// 3. Update CartResponse (if it includes other fields like _id, userId)
struct CartResponse: Codable {
    // Add other fields returned by your API root cart object
    let id: String?          // Optional: if your API returns the cart's _id
    let userId: String?      // Optional: if your API returns the userId
    let items: [CartItemResponse]
    let createdAt: String // Keep or change to Date if you configure decoder
    let updatedAt: String // Keep or change to Date

    // Adjust CodingKeys if needed
     enum CodingKeys: String, CodingKey {
         case id = "_id" // Example mapping
         case userId
         case items
         case createdAt
         case updatedAt
     }
}

// Keep Request Body Structs as they are correct for sending data TO the API
struct AddCartItemRequest: Encodable {
    let productId: String
    let quantity: Int
}

struct UpdateCartItemRequest: Encodable {
    let quantity: Int
}

// Protocol for testability (Dependency Inversion)
protocol CartServicing {
    func getCart() async throws -> CartResponse
    func addItem(productId: String, quantity: Int) async throws -> CartResponse // API returns updated cart
    func updateItemQuantity(productId: String, quantity: Int) async throws -> CartResponse // API returns updated cart
    func removeItem(productId: String) async throws -> CartResponse // API returns updated cart
    func clearCart() async throws // API returns 204 No Content
}

// Concrete implementation of the Cart Service
class CartService: CartServicing, ObservableObject {
    private let apiClient: ApiClient // Depends on ApiClient
    
    // Inject the ApiClient dependency
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    // --- Implement CartServicing protocol methods ---
    
    func getCart() async throws -> CartResponse {
        print("CartService: Fetching cart...")
        // Call the generic request function with specific endpoint and response type
        return try await apiClient.request(
            endpoint: .getCart, // Use the enum case
            body: Optional<EmptyBody>.none,
            responseType: CartResponse.self // Specify the expected Decodable struct
            // No body needed for GET
        )
    }
    
    func addItem(productId: String, quantity: Int) async throws -> CartResponse {
        print("CartService: Adding/updating item - Product ID: \(productId), Quantity: \(quantity)")
        // Prepare the request body
        let requestBody = AddCartItemRequest(productId: productId, quantity: quantity)
        
        // Call the generic request function
        return try await apiClient.request(
            // *** FIX: Provide associated values for the enum case ***
            endpoint: .addCartItem(productId: productId, quantity: quantity),
            body: requestBody,        // Pass the encoded body
            responseType: CartResponse.self // Specify expected response
        )
    }
    
    func updateItemQuantity(productId: String, quantity: Int) async throws -> CartResponse {
        print("CartService: Setting item quantity - Product ID: \(productId), Quantity: \(quantity)")
        // Prepare the request body
        let requestBody = UpdateCartItemRequest(quantity: quantity)
        
        // Call the generic request function
        return try await apiClient.request(
            endpoint: .updateCartItemQuantity(productId: productId, quantity: quantity), // Use enum case
            body: requestBody,        // Pass encoded body
            responseType: CartResponse.self // Specify expected response
        )
    }
    
    func removeItem(productId: String) async throws -> CartResponse {
        print("CartService: Removing item - Product ID: \(productId)")
        // DELETE requests usually don't have a body
        // Your API returns the updated cart according to the CartServicing protocol
        return try await apiClient.request(
            endpoint: .removeCartItem(productId: productId), // Use enum case
            body: Optional<EmptyBody>.none,
            responseType: CartResponse.self // Expecting updated cart based on protocol
        )
    }
    
    func clearCart() async throws {
        print("CartService: Clearing cart...")
        // Call the generic request function, expecting no content back
        // Use the special EmptyResponse type to handle 204 status code
        _ = try await apiClient.request(
            endpoint: .clearCart,
            body: Optional<EmptyBody>.none,
            responseType: EmptyResponse.self // Expecting no data in the response body
        )
        // Return void on success
    }
}
