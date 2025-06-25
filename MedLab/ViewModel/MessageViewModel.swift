//
//  MessageViewModel.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 28/5/25.
//

import SwiftUI

@MainActor
class MessageViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var adminMessages: [Message] = []
    @Published var currentInput: String = ""
    @Published var isBotTyping: Bool = false
    @Published var isLoadingHistory: Bool = false
    @Published var errorMessage: String? = nil
    
    private let messageService: MessageServicing
    private let webSocketService: WebSocketService?
    private var userId: String
    private var hasLoadedHistory = false // To prevent multiple history loads
    private let isAIChatEnabled: Bool
    
    init(messageService: MessageServicing, webSocketService: WebSocketService?, userId: String, isAIChatEnabled: Bool) {
        self.messageService = messageService
        self.webSocketService = webSocketService
        self.userId = userId
        self.isAIChatEnabled = isAIChatEnabled
        
        if !isAIChatEnabled && webSocketService != nil {
            listenToWebSocket()
        }
    }
    
    func listenToWebSocket() {
        webSocketService!.onMessageReceived = { [weak self] incoming in
            Task { @MainActor in
                self?.adminMessages.append(
                    Message(
                        message: incoming.message,
                        senderType: incoming.senderType,
                        date: incoming.createdAt ?? Date()
                    )
                )
                self?.isBotTyping = false
            }
        }
    }
    
    func loadChatHistory() async {
        // Only load history once, or if explicitly requested (e.g., pull to refresh)
        guard !hasLoadedHistory && !isLoadingHistory else { return }
        
        print("ChatViewModel: Loading chat history...")
        isLoadingHistory = true
        errorMessage = nil
        
        do {
            let historyResponse = try await messageService.fetchMessages()
            let historyMessages = historyResponse.messages
            let historyAdminMessages = historyResponse.adminMessage
            self.messages = historyMessages.sorted(by: { $0.date < $1.date })
            self.adminMessages = historyAdminMessages.sorted(by: { $0.date < $1.date })
            self.hasLoadedHistory = true
            print("ChatViewModel: Loaded \(self.messages.count)-\(self.adminMessages.count) historical messages.")
        } catch {
//            if (error)
            handleAPIError(error, context: "loading chat history")
        }
        isLoadingHistory = false
    }
    
    func sendMessageToWebSocket() {
        let userMessage = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userMessage.isEmpty && !isAIChatEnabled && webSocketService != nil else { return }
        
        messages.append(Message(message: userMessage, senderType: "user", date: Date()))
        currentInput = ""
        
        let request = MessageRequest(message: userMessage, senderType: "user", userId: userId)
        webSocketService!.send(message: request)
    }
    
    func sendMessage() {
        let userMessage = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // conditions check
        guard !userMessage.isEmpty, !isBotTyping else { return }
        
        // append to messages to update UI
        messages.append(Message(message: userMessage, senderType: "user", date: Date()))
        
        // set properties
        currentInput = ""
        isBotTyping = true
        errorMessage = nil
        
        Task {
            do {
                let apiResponse = try await messageService.generateMessage(message: userMessage)
                messages.append(Message(message: apiResponse.message, senderType: "ai", date: Date()))
            } catch {
                handleAPIError(error, context: "sending message")
            }
            isBotTyping = false
        }
    }
    
    private func handleAPIError(_ error: Error, context: String) {
        print("❌ ChatViewModel: Error \(context) - \(error)")
        let displayError: String
        if let apiClientError = error as? ApiClientError {
            switch apiClientError {
            case .authenticationError: displayError = "Authentication failed."
            case .networkError: displayError = "Network error. Please check connection."
            case .requestFailed(let statusCode, _):
                if statusCode == 404 {return}
                displayError = "Could not connect to service (Code: \(statusCode))."
            default: displayError = "Sorry, an error occurred."
            }
        } else {
            displayError = "An unexpected error occurred."
        }
        self.errorMessage = displayError
    }
    
    func clearLocalData() {
        messages = []
        adminMessages = []
        currentInput = ""
        isBotTyping = false
        isLoadingHistory = false
        errorMessage = nil
        hasLoadedHistory = false // Allow reloading history for next user
    }
}
