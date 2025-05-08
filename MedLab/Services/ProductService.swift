//
//  ProductService.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 3/4/25.
//

import Foundation

struct ProductResponse: Codable {
    let total: Int
    let totalPages: Int
    let currentPage: Int
    let products: [Product]
}

protocol ProductServicing {
    func fetchProducts(
        page: Int?,
        limit: Int?,
        category: String?
//        searchTerms: String? // implement later
    ) async throws -> ProductResponse
}

class ProductService: ProductServicing, ObservableObject {
//    static let shared = ProductService()
    private let apiClient: ApiClient
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    func fetchProducts(page: Int? = nil, limit: Int? = nil, category: String? = nil) async throws -> ProductResponse {
        return try await apiClient.request(
            endpoint: .getProducts(page: page, limit: limit, category: category),
            body: Optional<EmptyBody>.none,
            responseType: ProductResponse.self
        )
    }
    
//    func fetchProducts(page: Int? = nil, limit: Int? = nil, category: String? = nil) async throws -> ProductResponse {
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
//        
//        // Decode to your model
//        let product = try JSONDecoder().decode(ProductResponse.self, from: data)
//        return product
//    }
}
