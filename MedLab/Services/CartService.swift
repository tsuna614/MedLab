//
//  CartService.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 22/4/25.
//

import Foundation

struct CartItemResponse: Codable {
    let productId: String
    let quantity: Int
}

struct CartResponse: Codable {
    let items: [CartItemResponse]
    let createdAt: String
    let updatedAt: String
}

class CartService {
    static let shared = CartService()
    
//    func fetchProduct(page: Int? = nil, limit: Int? = nil, category: String? = nil) async throws -> ProductResponse {
//        var components = URLComponents(string: "http://localhost:3000/products")!
//        
//        var queryItems: [URLQueryItem] = []
//        
//        if let page = page {
//            queryItems.append(URLQueryItem(name: "page", value: String(page)))
//        }
//        
//        if let limit = limit {
//            queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
//        }
//        
//        if let category = category {
//            queryItems.append(URLQueryItem(name: "category", value: String(category)))
//        }
//        
//        components.queryItems = queryItems
//        
//        guard let url = components.url else {
//            throw URLError(.badURL)
//        }
//        
//        print("Fetching from API")
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        
//        // Await the URLSession call
//        let (data, _) = try await URLSession.shared.data(for: request)
        
//        // Decode to your model
//        let product = try JSONDecoder().decode(ProductResponse.self, from: data)
//        return product
//    }
    
//    func getCart() async throws -> CartResponse {
//        
//        guard let accessToken = UserDefaultsService.shared.getAccessToken() else {
//            print("ApiClient: Auth token missing.")
//            throw URLError(.unknown)
//        }
//        var components = URLComponents(string: "http://localhost:3000/products")!
//        
////        components.
//    }
}

