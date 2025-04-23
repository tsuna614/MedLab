//
//  ApiClient.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 22/4/25.
//

import Foundation

class ApiClient {

    // Base URL for your backend API
    private let baseURL: URL

    // Shared URLSession instance
    private let session: URLSession

    // Used for encoding request bodies and decoding responses
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()

    // --- Initialization ---
    init(baseURLString: String, session: URLSession = .shared) {
        guard let url = URL(string: baseURLString) else {
            fatalError("Invalid base URL string provided.") // Or handle more gracefully
        }
        self.baseURL = url
        self.session = session
        // Configure decoder/encoder if needed (e.g., date strategies)
        // jsonDecoder.dateDecodingStrategy = .iso8601
    }

    // --- Generic Request Function ---
    /// Performs a network request.
    /// - Parameters:
    ///   - endpoint: The ApiEndpoint defining the path and method.
    ///   - body: An optional Encodable object to send as the request body.
    ///   - responseType: The Decodable type expected for a successful response.
    ///   - requiresAuth: Whether an authentication token is needed.
    /// - Returns: An instance of the `responseType`.
    /// - Throws: An `ApiClientError` if the request fails.
    func request<T: Decodable, B: Encodable>(
        endpoint: ApiEndpoint,
        body: B? = nil, // Make body optional and generic
        responseType: T.Type = T.self, // Default to inferring T
        requiresAuth: Bool = true
    ) async throws -> T {

        // 1. Construct the full URL
        guard let url = URL(string: endpoint.path, relativeTo: baseURL) else {
            throw ApiClientError.invalidURL
        }

        // 2. Create URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method

        // 3. Add Headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // 4. Add Authentication (Placeholder - Implement actual token retrieval)
        if requiresAuth {
            guard let token = getAuthToken() else { // Replace with your token logic
                throw ApiClientError.authenticationError
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // 5. Encode Request Body (if provided)
        if let body = body {
            do {
                request.httpBody = try jsonEncoder.encode(body)
            } catch {
                throw ApiClientError.encodingError(error)
            }
        }

        // 6. Perform the Request
        let data: Data
        let response: URLResponse
        do {
            print("🚀 Requesting (\(request.httpMethod ?? "")): \(request.url?.absoluteString ?? "Invalid URL")")
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
             print("❌ Network Error: \(error.localizedDescription)")
            // Handle specific URLErrors if needed (e.g., .notConnectedToInternet)
            throw ApiClientError.networkError(error)
        } catch {
            print("❌ Unknown Network Error: \(error)")
            throw ApiClientError.unknownError
        }


        // 7. Validate Response Status Code
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid HTTP Response")
            throw ApiClientError.unknownError // Should not happen with http requests
        }

        print("✅ Response Status Code: \(httpResponse.statusCode)")

        guard (200...299).contains(httpResponse.statusCode) else {
             print("❌ Request Failed (\(httpResponse.statusCode)): \(String(data: data, encoding: .utf8) ?? "No Data")")
            throw ApiClientError.requestFailed(statusCode: httpResponse.statusCode, data: data)
        }

        // 8. Decode Response Body (if expected)
        // Handle empty responses (e.g., for DELETE or status 204)
        if T.self == EmptyResponse.self || data.isEmpty {
             guard let empty = EmptyResponse() as? T else {
                 // This should ideally not happen if T is EmptyResponse
                 throw ApiClientError.decodingError(DecodingError.typeMismatch(T.self, DecodingError.Context(codingPath: [], debugDescription: "Expected EmptyResponse but type mismatch")))
             }
             return empty
         }


        do {
            let decodedObject = try jsonDecoder.decode(T.self, from: data)
            return decodedObject
        } catch let error as DecodingError {
            print("❌ Decoding Error: \(error)")
            // Log more details from the decoding error if needed
            // print(String(data: data, encoding: .utf8) ?? "Could not print response data")
            throw ApiClientError.decodingError(error)
        } catch {
            print("❌ Unknown Decoding Error: \(error)")
            throw ApiClientError.unknownError
        }
    }

    // --- Placeholder for Authentication ---
    // Replace this with your actual mechanism to securely retrieve the user's auth token
    private func getAuthToken() -> String? {
        // Example: Retrieve from Keychain, UserDefaults (less secure), or an Auth Service
        // For testing: return "your_dummy_test_token"
        // In production: return SecureStorage.shared.getAuthToken() // Or similar
        print("⚠️ WARNING: Using placeholder getAuthToken(). Implement actual token retrieval.")
        // Return nil to test authentication error path
         return "your_dummy_test_token" // REPLACE THIS
    }
    
    func getCart() async throws -> CartResponse {
            let endpoint = ApiEndpoint.getCart // Use the enum

            // 1. Construct the full URL
            guard let url = URL(string: endpoint.path, relativeTo: baseURL) else {
                throw ApiClientError.invalidURL
            }

            // 2. Create URLRequest
            var request = URLRequest(url: url)
            request.httpMethod = endpoint.method

            // 3. Add Headers (including Authorization)
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            // 4. Get Token and Add Custom Auth Header
            guard let token = UserDefaultsService.shared.getAccessToken(), !token.isEmpty else {
                 print("❌ ApiClient: Auth token missing.")
                throw ApiClientError.authenticationError // Throw specific error
            }
            request.setValue(token, forHTTPHeaderField: "x_authorization") // <<< SET HEADER HERE
            print("ℹ️ ApiClient: Using x_authorization header.")


            // 5. Perform the Request
            let data: Data
            let response: URLResponse
            do {
                print("🚀 Requesting (\(request.httpMethod ?? "")): \(request.url?.absoluteString ?? "Invalid URL")")
                (data, response) = try await session.data(for: request)
            } catch let error as URLError {
                 print("❌ Network Error: \(error.localizedDescription)")
                throw ApiClientError.networkError(error)
            } catch {
                print("❌ Unknown Network Error: \(error)")
                throw ApiClientError.unknownError
            }

            // 6. Validate Response Status Code
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid HTTP Response")
                throw ApiClientError.unknownError
            }

            print("✅ Response Status Code: \(httpResponse.statusCode)")

            guard (200...299).contains(httpResponse.statusCode) else {
                 let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
                 print("❌ Request Failed (\(httpResponse.statusCode)): \(responseBody)")
                 // Check specifically for 401 Unauthorized
                 if httpResponse.statusCode == 401 {
                     throw ApiClientError.authenticationError // Map 401 to specific error
                 }
                throw ApiClientError.requestFailed(statusCode: httpResponse.statusCode, data: data)
            }

            // 7. Decode Response Body
            do {
                 // Print raw response data for debugging if needed
                 // print("Raw Response Data:\n\(String(data: data, encoding: .utf8) ?? "Could not decode data")")
                let decodedObject = try jsonDecoder.decode(CartResponse.self, from: data)
                return decodedObject
            } catch let error as DecodingError {
                print("❌ Decoding Error: \(error)")
                // Log more details from the decoding error if needed
                 switch error {
                 case .keyNotFound(let key, let context):
                     print("Key '\(key)' not found:", context.debugDescription)
                     print("codingPath:", context.codingPath)
                 case .valueNotFound(let value, let context):
                     print("Value '\(value)' not found:", context.debugDescription)
                     print("codingPath:", context.codingPath)
                 case .typeMismatch(let type, let context):
                     print("Type '\(type)' mismatch:", context.debugDescription)
                     print("codingPath:", context.codingPath)
                 case .dataCorrupted(let context):
                     print("Data corrupted:", context.debugDescription)
                     print("codingPath:", context.codingPath)
                 @unknown default:
                     print("Unknown decoding error: \(error.localizedDescription)")
                 }
                 print("Attempted to decode response: \(String(data: data, encoding: .utf8) ?? "Invalid UTF-8 data")")

                throw ApiClientError.decodingError(error)
            } catch {
                print("❌ Unknown Decoding Error: \(error)")
                throw ApiClientError.unknownError
            }
        }
}

// Helper struct for requests that expect no response body (e.g., DELETE, 204 No Content)
struct EmptyResponse: Codable {}
