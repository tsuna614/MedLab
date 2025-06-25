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
    
    // User Endpoints
    case fetchUser
    case updateUser
    
    // Cart Endpoints
    case getCart
    case addCartItem(productId: String, quantity: Int)
    case updateCartItemQuantity(productId: String, quantity: Int)
    case removeCartItem(productId: String)
    case clearCart

    // Product Endpoints
    case getProducts(page: Int?, limit: Int?, category: String?)
    case getProductDetail(productId: String) // Fetch details for one product

    // Order endpoints
    case getOrders
    case createOrder
    
    // Message endpoints
    case fetchMessage
    case generateMessage
    
    // Doctor endpoints
    case getDoctors(page: Int?, limit: Int?)
    
    // Voucher endpoints
    case getVouchers
    case redeemVoucher

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
        case .createOrder:
            return "/orders"
        case .getOrders:
            return "/orders/getAllUserOrder"
            
        // User Paths
        case .fetchUser, .updateUser:
            return "/users"
            
        // Doctor Paths
        case .getDoctors:
            return "/doctors"
            
        // Voucher Paths
        case .getVouchers:
            return "/vouchers"
        case .redeemVoucher:
            return "/vouchers/redeemVoucher"
            
        // Message paths
        case .fetchMessage:
            return "/messages/fetchAIMessages"
        case .generateMessage:
            return "/messages/generateAIMessage"
        }
    }

    var method: String {
        switch self {
        // Cart Methods
        case .getCart, .getProductDetail, .getProducts, .getOrders, .fetchUser, .fetchMessage, .getDoctors, .getVouchers:
            return "GET"
        case .addCartItem, .createOrder, .login, .register, .generateMessage, .redeemVoucher:
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
        case .getDoctors(let page, let limit):
            var items: [URLQueryItem] = []
            if let page = page { items.append(URLQueryItem(name: "page", value: String(page))) }
            if let limit = limit { items.append(URLQueryItem(name: "limit", value: String(limit))) }
            items.append(URLQueryItem(name: "isVisible", value: String("true")))
            return items.isEmpty ? nil : items
//        case .getVouchers(let page, let limit):
//            var items: [URLQueryItem] = []
//            if let page = page { items.append(URLQueryItem(name: "page", value: String(page))) }
//            if let limit = limit { items.append(URLQueryItem(name: "limit", value: String(limit))) }
//            items.append(URLQueryItem(name: "isVisible", value: String("true")))
//            return items.isEmpty ? nil : items
        
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
                .getProductDetail,
                .getDoctors,
                .getVouchers:
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
                .updateUser,
                .fetchMessage,
                .generateMessage,
                .redeemVoucher:
            return true
        }
    }
}

//struct BackendProductListResponse: Codable {
//    let products: [BackendProductSummary]
//}
//
//struct BackendProductSummary: Codable {
//    let id: String
//    let name: String
//    let price: Double
//    let imageUrl: String?
//}
