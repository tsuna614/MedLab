//
//  WebSocketService.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 24/6/25.
//

import Foundation

//class WebSocketService: ObservableObject {
//    private var webSocketTask: URLSessionWebSocketTask?
//    private let url: URL
//
//    @Published var receivedMessages: [String] = []
//
//    init(urlString: String) {
//        self.url = URL(string: urlString)!
//    }
//
//    func connect() {
//        let request = URLRequest(url: url)
//        webSocketTask = URLSession.shared.webSocketTask(with: request)
//        webSocketTask?.resume()
//        receiveMessage()
//        print("WebSocket connected")
//    }
//
//    func disconnect() {
//        webSocketTask?.cancel(with: .goingAway, reason: nil)
//        print("WebSocket disconnected")
//    }
//
//    func send(message: MessageRequest) {
//        do {
//            let jsonData = try JSONEncoder().encode(message)
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                let webSocketMessage = URLSessionWebSocketTask.Message.string(jsonString)
//                webSocketTask?.send(webSocketMessage) { error in
//                    if let error = error {
//                        print("WebSocket send error: \(error)")
//                    } else {
//                        print("Message sent successfully")
//                    }
//                }
//            }
//        } catch {
//            print("Encoding error: \(error)")
//        }
//    }
//
//
//    private func receiveMessage() {
//        webSocketTask?.receive { [weak self] result in
//            switch result {
//            case .failure(let error):
//                print("WebSocket receive error: \(error)")
//            case .success(let message):
//                switch message {
//                case .string(let text):
//                    DispatchQueue.main.async {
//                        self?.receivedMessages.append(text)
//                    }
//                case .data(let data):
//                    print("Received data: \(data)")
//                @unknown default:
//                    break
//                }
//                // Continue receiving
//                self?.receiveMessage()
//            }
//        }
//    }
//}

import Foundation

struct MessageResponse: Codable {
    let message: String
    let senderType: String
    let userId: String
    let createdAt: Date?
}

struct MessageRequest: Codable {
    let message: String
    let senderType: String
    var userId: String
}

final class WebSocketService: NSObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private let urlSession: URLSession
    
    var onMessageReceived: ((MessageResponse) -> Void)?
    
    init(url: URL) {
        self.urlSession = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        self.webSocketTask = urlSession.webSocketTask(with: url)
        self.webSocketTask?.resume()
        super.init()
        listen()
    }
    
    func listen() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("❌ WebSocket receive error: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    do {
                        let data = Data(text.utf8)
                        let decoded = try JSONDecoder().decode(MessageResponse.self, from: data)
                        self?.onMessageReceived?(decoded)
                    } catch {
                        print("❌ Failed to decode message: \(error)")
                    }
                default:
                    print("⚠️ Unsupported WebSocket message format.")
                }
            }
            self?.listen() // Continue listening
        }
    }
    
    func send(message: MessageRequest) {
        do {
            let jsonData = try JSONEncoder().encode(message)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else { return }
            let wsMessage = URLSessionWebSocketTask.Message.string(jsonString)
            webSocketTask?.send(wsMessage) { error in
                if let error = error {
                    print("❌ WebSocket send error: \(error)")
                } else {
                    print("✅ Message sent")
                }
            }
        } catch {
            print("❌ WebSocket encoding error: \(error)")
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}
