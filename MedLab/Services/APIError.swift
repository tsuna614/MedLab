//
//  APIError.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 31/3/25.
//

import Foundation

enum AuthException: Error, LocalizedError {
    case serverError(String)
    case invalidData
    case unknown

    var errorDescription: String? {
        switch self {
        case .serverError(let message):
            return message
        case .invalidData:
            return "Received invalid data from the server."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}

enum ApiClientError: Error {
    case invalidURL
    case networkError(Error) // Wraps underlying network errors (e.g., no connection)
    case requestFailed(statusCode: Int, data: Data?) // Non-2xx status code
    case decodingError(Error) // Failed to parse JSON response
    case encodingError(Error) // Failed to encode request body
    case authenticationError // Missing or invalid auth token
    case unknownError
}
