//
//  ApiEndpoint.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 22/4/25.
//

import Foundation

enum ApiEndpoint {
    // Auth Services
    case login
    case register
    
    // Cart Endpoints
    case getCart
    case addCartItem(productId: String, quantity: Int)
    case updateCartItemQuantity(productId: String, quantity: Int)
    case removeCartItem(productId: String)
    case clearCart

    // Product Endpoints (NEW)
    case getProducts(page: Int?, limit: Int?, category: String?)
    case getProductDetail(productId: String) // Fetch details for one product

    // Add other endpoints as needed (e.g., auth, orders)
    case getOrders
    case createOrder(orderData: CreateOrderRequest)
    
    // User Endpoints
    case fetchUser
    case updateUser

    // Computed properties to define path and method
    var path: String {
        switch self {
        // Auth Paths
        case .login:
            return "/auth/login"
        case .register:
            return "/auth/register"
            
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
            return "/products" // Standard path for listing resources
        case .getProductDetail(let productId):
            return "/products/\(productId)" // Standard path for a specific resource
            
        // Order Paths
        case .getOrders, .createOrder:
            return "/orders"
            
        // User Paths
        case .fetchUser, .updateUser:
            return "/users"
        }
        
        
    }

    var method: String {
        switch self {
        // Cart Methods
        case .getCart, .getProductDetail, .getProducts, .getOrders, .fetchUser:
            return "GET"
        case .addCartItem, .createOrder, .login, .register:
            return "POST"
        case .updateCartItemQuantity, .updateUser:
            return "PUT"
        case .removeCartItem, .clearCart:
            return "DELETE"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .getProducts(let page, let limit, let category):
            var items: [URLQueryItem] = []
            if let page = page { items.append(URLQueryItem(name: "page", value: String(page))) }
            if let limit = limit { items.append(URLQueryItem(name: "limit", value: String(limit))) }
            if let category = category, !category.isEmpty { items.append(URLQueryItem(name: "category", value: category)) }
//            if let searchTerm = searchTerm, !searchTerm.isEmpty { items.append(URLQueryItem(name: "search", value: searchTerm)) } // Assuming "search" is the query param name
            return items.isEmpty ? nil : items
        default:
            return nil
        }
    }
    
    var requiresAuth: Bool {
        switch self {
        case
                .login,
                .register,
                .getProducts,
                .getProductDetail:
            return false
            
        case
                .getCart,
                .addCartItem,
                .updateCartItemQuantity,
                .removeCartItem,
                .clearCart,
                .getOrders,
                .createOrder,
                .fetchUser,
                .updateUser:
            return true
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
