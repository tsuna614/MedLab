//
//  ApiEndpoint.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 22/4/25.
//

import Foundation

enum ApiEndpoint {
    // Cart Endpoints
    case getCart
    case addCartItem(productId: String, quantity: Int)
    case updateCartItemQuantity(productId: String, quantity: Int)
    case removeCartItem(productId: String)
    case clearCart

    // Product Endpoints (NEW)
    case getProducts // Fetch a list of products (could add params for filtering/pagination later)
    case getProductDetail(productId: String) // Fetch details for one product

    // Add other endpoints as needed (e.g., auth, orders)

    // Computed properties to define path and method
    var path: String {
        switch self {
        // Cart Paths
        case .getCart:
            return "/carts"
        case .addCartItem:
            return "/carts"
        case .updateCartItemQuantity(let productId, _):
            return "/carts/items/\(productId)"
        case .removeCartItem(let productId):
            return "/carts/items/\(productId)"
        case .clearCart:
            return "/carts"

        // Product Paths (NEW)
        case .getProducts:
            return "/api/products" // Standard path for listing resources
        case .getProductDetail(let productId):
            return "/api/products/\(productId)" // Standard path for a specific resource
        }
    }

    var method: String {
        switch self {
        // Cart Methods
        case .getCart:
            return "GET"
        case .addCartItem:
            return "POST"
        case .updateCartItemQuantity:
            return "PUT"
        case .removeCartItem:
            return "DELETE"
        case .clearCart:
            return "DELETE"

        // Product Methods (NEW)
        case .getProducts:
            return "GET" // Fetching lists is usually GET
        case .getProductDetail:
            return "GET" // Fetching a specific item is usually GET
        }
    }
}

// --- You would also need corresponding Response Structs ---

// Example for GET /api/products (adjust to match your actual API response)
struct BackendProductListResponse: Codable {
    // Assuming your API returns an array directly, or wraps it in a structure
    let products: [BackendProductSummary] // Or maybe the full Product model if appropriate
    // Add pagination info if your API includes it (e.g., totalPages, currentPage)
}

struct BackendProductSummary: Codable { // Or use your full Product model if API returns it
    let id: String // Assuming API uses "_id" mapped via CodingKeys in full model
    let name: String
    let price: Double
    let imageUrl: String?
    // Include other summary fields needed for list display
}

// Example for GET /api/products/{productId}
// Often, this might just return your full `Product` model,
// assuming it's Codable and maps correctly to the API JSON.
// If not, create a specific `BackendProductDetailResponse` struct.
