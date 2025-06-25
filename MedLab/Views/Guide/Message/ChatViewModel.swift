////
////  ChatViewModel.swift
////  MedLab
////
////  Created by Khanh Nguyen Quoc on 24/6/25.
////
//
//import SwiftUI
//import Combine
//
//@MainActor
//class ChatViewModel: ObservableObject {
//    @Published var messages: [ChatMessage] = [] // Uses the UI model
//    @Published var currentInput: String = ""
//    @Published var isBotTyping: Bool = false // Might be set based on WebSocket messages
//    @Published var connectionStatusMessage: String = "Connecting..."
//    @Published var isConnected: Bool = false
//
//    private let webSocketService: WebSocketService
//    private var cancellables = Set<AnyCancellable>()
//
//    // User info needed for connection (passed from AppViewModel or auth state)
//    private let userId: String
//    private let isAdmin: Bool
//
//    init(userId: String, isAdmin: Bool, webSocketService: WebSocketService) {
//        self.userId = userId
//        self.isAdmin = isAdmin
//        self.webSocketService = webSocketService
//        
//        // Observe messages from WebSocketService
//        webSocketService.$receivedMessages
//            .receive(on: DispatchQueue.main) // Ensure updates on main thread
//            .assign(to: &$messages) // Directly assign if types match or map if needed
//
//        // Observe connection status
//        webSocketService.$isConnected
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] connected in
//                self?.isConnected = connected
//                self?.connectionStatusMessage = connected ? "Connected" : "Disconnected. Tap to retry."
//                if connected {
//                    self?.isBotTyping = false // Reset typing on connect
//                }
//            }
//            .store(in: &cancellables)
//
//        // Observe errors
//        webSocketService.$connectionError
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] errorMsg in
//                if let errorMsg = errorMsg, !errorMsg.isEmpty {
//                    self?.connectionStatusMessage = errorMsg
//                    // Optionally add error to messages list as a bot message
//                    // self?.messages.append(ChatMessage(text: "Error: \(errorMsg)", isUser: false))
//                }
//            }
//            .store(in: &cancellables)
//
//        connectWebSocket() // Initial connection attempt
//    }
//
//    func connectWebSocket() {
//        connectionStatusMessage = "Connecting..."
//        webSocketService.connect(userId: self.userId, isAdmin: self.isAdmin)
//    }
//
//    func disconnectWebSocket() {
//        webSocketService.disconnect()
//    }
//
//    func sendMessage() {
//        let textToSend = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !textToSend.isEmpty, isConnected else { return }
//
//        // Optimistically add user's message to UI
//        // The WebSocketService will receive this back from the server if broadcasted,
//        // OR the server might only send the bot's reply.
//        // If your server broadcasts the user's own message back, you might get duplicates.
//        // For now, let's assume server only sends bot replies to the originating user.
//        let userMessage = ChatMessage(text: textToSend, isUser: true, userId: self.userId, senderType: self.isAdmin ? "admin" : "user")
//        // self.messages.append(userMessage) // Optimistic add. Consider if server echoes it back.
//
//        webSocketService.sendMessage(text: textToSend) // Send to backend via WebSocket
//        currentInput = ""
//        isBotTyping = true // Assume bot will reply
//        // The bot's reply will arrive via webSocketService.$receivedMessages
//    }
//
//    deinit {
//        webSocketService.disconnect() // Ensure disconnection when ViewModel is deallocated
//    }
//}
