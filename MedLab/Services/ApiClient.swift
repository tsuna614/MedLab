//
//  ApiClient.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 22/4/25.
//

import Foundation

class ApiClient: ObservableObject {
    private let baseURL: URL
    private let session: URLSession
    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder: JSONDecoder

    init(baseURLString: String, session: URLSession = .shared) {
        guard let url = URL(string: baseURLString) else {
            fatalError("Invalid base URL string provided.")
        }
        self.baseURL = url
        self.session = session
        
        // *** CONFIGURE THE DECODER WITH CUSTOM ISO8601 PARSING ***
        self.jsonDecoder = JSONDecoder()
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        self.jsonDecoder.dateDecodingStrategy = .custom({ decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            if let date = isoFormatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString) as ISO8601.")
        })
        // *** END CUSTOM CONFIGURATION ***
        
        print("ApiClient: JSONDecoder configured with CUSTOM ISO8601 date strategy.")
    }

    /// Generic function to make API requests.
    /// - Parameters:
    ///   - endpoint: The ApiEndpoint case defining path and method.
    ///   - body: An optional Encodable object to send as the request body (for POST, PUT, etc.).
    ///   - responseType: The Decodable type expected in the response body on success.
    /// - Returns: The decoded object of type T.
    /// - Throws: ApiClientError for various request/response issues.
    func request<T: Decodable, B: Encodable>(
        endpoint: ApiEndpoint,
        body: B? = nil, // Make body optional and generic
        responseType: T.Type
    ) async throws -> T {

        // 1. Construct URL
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false)
        components?.queryItems = endpoint.queryItems
        
        guard let url = components?.url else {
            print("❌ ApiClient: Failed to create URL for path \(endpoint.path)")
            throw ApiClientError.invalidURL
        }

        // 2. Create URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method

        // 3. Set Common Headers
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if body != nil { // Only set Content-Type if there's a body
             request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }


        // 4. Add Authorization Header
        // Fetch token ONLY if the endpoint requires authentication
        if endpoint.requiresAuth {
            if let token = UserDefaultsService.shared.getAccessToken(), !token.isEmpty {
                request.setValue(token, forHTTPHeaderField: "x_authorization")
                // print("ℹ️ ApiClient: Added x_authorization header.")
            } else {
                // Decide how to handle missing token for protected routes.
                // Could throw immediately or let the server return 401.
                // Throwing early can be clearer.
                print("⚠️ ApiClient: No access token found for potentially protected route \(endpoint.path)")
                // Consider throwing ApiClientError.authenticationError here if endpoint requires auth
            }            
        }


        // 5. Encode Request Body (if provided)
        if let requestBody = body {
            do {
                request.httpBody = try jsonEncoder.encode(requestBody)
                // Optional: Print request body for debugging
                // if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
                //      print("ℹ️ Request Body: \(bodyString)")
                // }
            } catch let error as EncodingError {
                print("❌ ApiClient: Failed to encode request body - \(error)")
                throw ApiClientError.encodingError(error)
            }
        }

        // 6. Perform Network Request
        let data: Data
        let response: URLResponse
        print("🚀 Requesting (\(request.httpMethod ?? "")): \(request.url?.absoluteString ?? "Invalid URL")")
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            print("❌ Network Error: \(error.code) - \(error.localizedDescription)")
            throw ApiClientError.networkError(error)
        } catch {
            print("❌ Unknown Network Error: \(error)")
            throw ApiClientError.unknownError
        }

        // 7. Validate Response Status Code
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid HTTP Response received.")
            throw ApiClientError.unknownError
        }

        print("✅ Response Status Code: \(httpResponse.statusCode)")

        guard (200...299).contains(httpResponse.statusCode) else {
            let responseBodyString = String(data: data, encoding: .utf8) ?? "No response body"
            print("❌ Request Failed (\(httpResponse.statusCode)): \(responseBodyString)")
            if httpResponse.statusCode == 401 {
                // Specific handling for unauthorized
                // Could trigger logout flow, refresh token logic, etc.
                print("Authentication Error (401). Token may be invalid or expired.")
                throw ApiClientError.authenticationError
            }
            // Throw general failure for other non-2xx codes
            throw ApiClientError.requestFailed(statusCode: httpResponse.statusCode, data: data)
        }

        // Handle 204 No Content specifically (common for DELETE)
        if httpResponse.statusCode == 204 || data.isEmpty {
             // If the expected response type T can handle being empty (e.g., an optional or a specific "success" type)
             // This requires careful handling based on what T is.
             // A common approach is to have specific functions for DELETE that don't expect a body.
             // For this generic function, if T expects data, decoding empty data will fail.
             // Let's assume for now that if T is expected, we need data.
            guard T.self != EmptyResponse.self else { // Check if expecting EmptyResponse specifically
                // swiftlint:disable:next force_cast
                return EmptyResponse() as! T // Return dummy EmptyResponse if that's expected
            }
             // If data is empty but T expects something, it's likely a decoding error will occur below, which is okay.
             print("⚠️ Response body is empty (Status Code \(httpResponse.statusCode)). Decoding might fail if response type expects data.")
        }


        // 8. Decode Response Body
        do {
            let decodedObject = try jsonDecoder.decode(T.self, from: data)
            return decodedObject
        } catch let error as DecodingError {
             // Provide detailed decoding error information
            print("❌ Decoding Error: \(error.localizedDescription)")
            logDecodingError(error, data: data)
            throw ApiClientError.decodingError(error)
        } catch {
            print("❌ Unknown error during decoding: \(error)")
            throw ApiClientError.unknownError
        }
    }
    
//    func request<T: Decodable>(
//        endpoint: ApiEndpoint,
//        responseType: T.Type
//    ) async throws -> T {
//        // ... (Implementation is similar but omits body encoding and Content-Type header) ...
//        // 1. Construct URL
//        guard let url = URL(string: endpoint.path, relativeTo: baseURL) else { throw ApiClientError.invalidURL }
//        // 2. Create Request
//        var request = URLRequest(url: url)
//        request.httpMethod = endpoint.method
//        // 3. Set Headers (Accept only)
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        // 4. Add Auth Header
//        if let token = UserDefaultsService.shared.getAccessToken(), !token.isEmpty {
//            request.setValue(token, forHTTPHeaderField: "x_authorization")
//        } else { /* Handle missing token */ }
//        // 5. NO BODY ENCODING
//        // 6. Perform Request
//        // ... (rest of request, validation, decoding logic - same as above) ...
//        // Again, factor out common logic.
//         print("🚀 Requesting (\(request.httpMethod ?? "")): \(request.url?.absoluteString ?? "Invalid URL")")
//         let (data, response) = try await session.data(for: request) // Placeholder
//         guard let httpResponse = response as? HTTPURLResponse else { throw ApiClientError.unknownError }
//         print("✅ Response Status Code: \(httpResponse.statusCode)")
//         guard (200...299).contains(httpResponse.statusCode) else {
//             let responseBodyString = String(data: data, encoding: .utf8) ?? "No response body"
//             print("❌ Request Failed (\(httpResponse.statusCode)): \(responseBodyString)")
//             if httpResponse.statusCode == 401 { throw ApiClientError.authenticationError }
//             throw ApiClientError.requestFailed(statusCode: httpResponse.statusCode, data: data)
//         }
//          if httpResponse.statusCode == 204 || data.isEmpty {
//             guard T.self != EmptyResponse.self else { return EmptyResponse() as! T }
//              // Potentially throw if data is empty but T isn't EmptyResponse
//              // throw ApiClientError.decodingError(...) // Or let decode fail below
//         }
//         do {
//             let decodedObject = try jsonDecoder.decode(T.self, from: data)
//             return decodedObject
//         } catch let error as DecodingError {
//             print("❌ Decoding Error: \(error.localizedDescription)")
//             logDecodingError(error, data: data) // Use your logging helper
//             throw ApiClientError.decodingError(error)
//         }
//    }

    // Helper for more detailed decoding error logs
    private func logDecodingError(_ error: DecodingError, data: Data) {
         switch error {
         case .keyNotFound(let key, let context):
             print("  Key '\(key.stringValue)' not found at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
             print("  Debug Description:", context.debugDescription)
         case .valueNotFound(let type, let context):
             print("  Value of type '\(type)' not found at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
             print("  Debug Description:", context.debugDescription)
         case .typeMismatch(let type, let context):
             print("  Type '\(type)' mismatch at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
             print("  Debug Description:", context.debugDescription)
         case .dataCorrupted(let context):
             print("  Data corrupted at path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
             print("  Debug Description:", context.debugDescription)
         @unknown default:
             print("  Unknown decoding error: \(error.localizedDescription)")
         }
         print("  Attempted to decode response: \(String(data: data, encoding: .utf8) ?? "Invalid UTF-8 data")")
     }
}

// Define an empty struct for endpoints that return no body (like 204 No Content)
struct EmptyResponse: Decodable {}

struct EmptyBody: Encodable {}
