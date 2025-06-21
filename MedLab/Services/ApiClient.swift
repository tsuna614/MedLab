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
        
        print("ApiClient: JSONDecoder configured with CUSTOM ISO8601 date strategy.")
    }
    
    func request<T: Decodable, B: Encodable>(
        endpoint: ApiEndpoint,
        body: B? = nil,
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
        if endpoint.requiresAuth {
            if let token = UserDefaultsService.shared.getAccessToken(), !token.isEmpty {
                request.setValue(token, forHTTPHeaderField: "x_authorization")
            } else {
                print("⚠️ ApiClient: No access token found for potentially protected route \(endpoint.path)")
            }
        }


        // 5. Encode Request Body
        if let requestBody = body {
            do {
                request.httpBody = try jsonEncoder.encode(requestBody)
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
                print("Authentication Error (401). Token may be invalid or expired.")
                throw ApiClientError.authenticationError
            }
            throw ApiClientError.requestFailed(statusCode: httpResponse.statusCode, data: data)
        }

        if httpResponse.statusCode == 204 || data.isEmpty {
            guard T.self != EmptyResponse.self else {
                return EmptyResponse() as! T
            }
             print("⚠️ Response body is empty (Status Code \(httpResponse.statusCode)). Decoding might fail if response type expects data.")
        }


        // 8. Decode Response Body
        do {
            let decodedObject = try jsonDecoder.decode(T.self, from: data)
            return decodedObject
        } catch let error as DecodingError {
            print("❌ Decoding Error: \(error.localizedDescription)")
            logDecodingError(error, data: data)
            throw ApiClientError.decodingError(error)
        } catch {
            print("❌ Unknown error during decoding: \(error)")
            throw ApiClientError.unknownError
        }
    }

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

struct EmptyResponse: Decodable {}

struct EmptyBody: Encodable {}
