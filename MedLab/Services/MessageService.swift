//
//  MessageService.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 28/5/25.
//

import Foundation

struct GenerateMessageRequest: Encodable {
    let message: String
}

struct GenerateMessageResponse: Decodable {
    let message: String
}

// --- Model for a single message in the UI ---
struct Message: Identifiable, Decodable {
    let message: String
    let senderType: String
    let date: Date
    
    var id: String { message + date.ISO8601Format() }
    
    enum CodingKeys: String, CodingKey {
        case message
        case senderType
        case date = "createdAt"
    }
}

struct FetchMessageResponse: Identifiable, Decodable {
    let id: String
    let userId: String
    let messages: [Message]
    let adminMessage: [Message]
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case userId
        case messages
        case adminMessage
    }
}

protocol MessageServicing {
    func fetchMessages() async throws -> FetchMessageResponse
    func generateMessage(message: String) async throws -> GenerateMessageResponse
}

class MessageService: MessageServicing, ObservableObject {
    private let apiClient: ApiClient
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    func fetchMessages() async throws -> FetchMessageResponse {
        print("Message Service: Fetching Messages...")
        return try await apiClient.request(
            endpoint: .fetchMessage,
            body: Optional<EmptyBody>.none,
            responseType: FetchMessageResponse.self
        )
    }
    
    func generateMessage(message: String) async throws -> GenerateMessageResponse {
        print("Message Service: Generating Message")
        
        let requestBody = GenerateMessageRequest(message: message)
        
        return try await apiClient.request(
            endpoint: .generateMessage,
            body: requestBody,
            responseType: GenerateMessageResponse.self)
    }
}

