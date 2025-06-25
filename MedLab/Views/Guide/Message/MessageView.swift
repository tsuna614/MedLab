//
//  MessageView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 30/3/25.
//

//import SwiftUI
//
//struct MessageView: View {
//    @StateObject private var messageViewModel: MessageViewModel
//    private let isAIChatEnabled: Bool
//
//    init(userId: String, isAIChatEnabled: Bool) {
//        self.isAIChatEnabled = isAIChatEnabled
//        
//        let webSocketServiceInstance: WebSocketService? = isAIChatEnabled ? nil : WebSocketService(url: URL(string: "ws://localhost:3000?id=\(userId)")!)
//            
//        
//        let messageServiceInstance = MessageService(apiClient: ApiClient(baseURLString: base_url))
//        _messageViewModel = StateObject(
//            wrappedValue: MessageViewModel(messageService: messageServiceInstance, webSocketService: webSocketServiceInstance, userId: userId, isAIChatEnabled: isAIChatEnabled))
//    }
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 0) {
//                contentView
//                botTypingIndicator
//                inputArea
//            }
//            .navigationTitle("AI Doctor Chat")
//            .navigationBarTitleDisplayMode(.inline)
//            .alert("Error", isPresented: .constant(messageViewModel.errorMessage != nil), actions: {
//                Button("OK") { messageViewModel.errorMessage = nil }
//            }) {
//                Text(messageViewModel.errorMessage ?? "An unknown error occurred.")
//            }
//            .onAppear {
//                Task {
//                    await messageViewModel.loadChatHistory()
//                }
//            }
//        }
//    }
//
//    @ViewBuilder
//    private var contentView: some View {
//        if messageViewModel.isLoadingHistory && messageViewModel.messages.isEmpty {
//            ProgressView("Loading history...")
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//        } else if !messageViewModel.isLoadingHistory && messageViewModel.messages.isEmpty && messageViewModel.errorMessage == nil {
//            emptyStateView
//        } else {
//            messageListView
//        }
//    }
//
//    private var emptyStateView: some View {
//        VStack {
//            Spacer()
//            Image(systemName: "message.badge.circle.fill")
//                .font(.system(size: 60))
//                .foregroundColor(.secondary)
//            Text("No Messages Yet")
//                .font(.title2)
//            Text("Start a conversation with the AI Doctor.")
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//            Spacer()
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//    }
//
//    private var messageListView: some View {
//        ScrollViewReader { scrollViewProxy in
//            ScrollView(.vertical) {
//                LazyVStack(spacing: 12) {
//                    ForEach(messageViewModel.messages) { message in
//                        MessageRow(message: message)
//                            .id(message.id)
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.top)
//            }
//            .onChange(of: messageViewModel.messages.count) {
//                if let lastMessage = messageViewModel.messages.last {
//                    withAnimation(.easeOut(duration: 0.25)) {
//                        scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
//                    }
//                }
//            }
//            .onAppear {
//                 if let lastMessage = messageViewModel.messages.last {
//                      scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
//                 }
//            }
//        }
//    }
//
//    @ViewBuilder
//    private var botTypingIndicator: some View {
//        if messageViewModel.isBotTyping {
//            HStack {
//                ProgressView().scaleEffect(0.7)
//                Text("AI Doctor is typing...").font(.caption).foregroundColor(.secondary)
//                Spacer()
//            }
//            .padding([.horizontal, .top], 10)
//            .padding(.bottom, 5)
//        }
//    }
//
//    private var inputArea: some View {
//        HStack(spacing: 10) {
//            TextField("Ask the AI Doctor...", text: $messageViewModel.currentInput, axis: .vertical)
//                .textFieldStyle(.plain)
//                .padding(10)
//                .background(Color(.systemGray6))
//                .cornerRadius(20)
//                .lineLimit(1...5)
//
//            Button {
//                messageViewModel.sendMessage()
//            } label: {
//                Image(systemName: "arrow.up.circle.fill")
//                    .font(.title)
//                    .foregroundColor(messageViewModel.currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || messageViewModel.isBotTyping ? .gray : .blue)
//            }
//            .disabled(messageViewModel.currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || messageViewModel.isBotTyping)
//        }
//        .padding()
//        .background(.thinMaterial)
//    }
//}
//
//struct MessageRow: View {
//    let message: Message
//    
//    var body: some View {
//        HStack {
//            if message.senderType == "user" {
//                Spacer()
//                Text(message.message)
//                    .padding(10).background(Color.blue).foregroundColor(.white)
//                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
//                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
//            } else {
//                Text(message.message)
//                    .padding(10).background(Color(.systemGray5)).foregroundColor(.primary)
//                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
//                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
//                Spacer()
//            }
//        }
//    }
//}

import SwiftUI

struct MessageView: View {
    @StateObject private var messageViewModel: MessageViewModel
    private let isAIChatEnabled: Bool

    init(userId: String, isAIChatEnabled: Bool) {
        self.isAIChatEnabled = isAIChatEnabled

        let webSocketService: WebSocketService? = isAIChatEnabled
            ? nil
            : WebSocketService(url: URL(string: "ws://localhost:3000?id=\(userId)")!)

        let messageService = MessageService(apiClient: ApiClient(baseURLString: base_url))
        _messageViewModel = StateObject(
            wrappedValue: MessageViewModel(
                messageService: messageService,
                webSocketService: webSocketService,
                userId: userId,
                isAIChatEnabled: isAIChatEnabled
            )
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                contentView
                typingIndicator
                inputArea
            }
            .navigationTitle(isAIChatEnabled ? "AI Doctor Chat" : "Admin Chat")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: .constant(messageViewModel.errorMessage != nil), actions: {
                Button("OK") { messageViewModel.errorMessage = nil }
            }) {
                Text(messageViewModel.errorMessage ?? "")
            }
            .onAppear {
                Task {
                    await messageViewModel.loadChatHistory()
                }
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        let convo = isAIChatEnabled
            ? messageViewModel.messages
            : messageViewModel.adminMessages

        if messageViewModel.isLoadingHistory && convo.isEmpty {
            ProgressView("Loading history...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if !messageViewModel.isLoadingHistory && convo.isEmpty && messageViewModel.errorMessage == nil {
            emptyStateView
        } else {
            messageListView(messages: convo)
        }
    }

    private var emptyStateView: some View {
        VStack {
            Spacer()
            Image(systemName: "message.badge.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No Messages Yet").font(.title2)
            Text(isAIChatEnabled
                 ? "Start a chat with the AI Doctor."
                 : "Start a chat with an admin.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func messageListView(messages: [Message]) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { msg in
                        MessageRow(message: msg)
                            .id(msg.id)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .onChange(of: messages.count) { oldValue, newValue in
                if newValue > oldValue, let last = messages.last {
                    withAnimation {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .onAppear {
                if let last = messages.last {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }

    @ViewBuilder
    private var typingIndicator: some View {
        if isAIChatEnabled && messageViewModel.isBotTyping {
            HStack {
                ProgressView().scaleEffect(0.7)
                Text("AI Doctor is typing...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
    }

    private var inputArea: some View {
        HStack(spacing: 10) {
            TextField(
                isAIChatEnabled ? "Ask the AI Doctor..." : "Write a message to admin...",
                text: $messageViewModel.currentInput,
                axis: .vertical
            )
            .textFieldStyle(.plain)
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(20)
            .lineLimit(1...5)

            Button {
                if isAIChatEnabled {
                    messageViewModel.sendMessage()
                } else {
                    messageViewModel.sendMessageToWebSocket()
                }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title)
                    .foregroundColor(canSend ? .blue : .gray)
            }
            .disabled(!canSend)
        }
        .padding()
        .background(.thinMaterial)
    }

    private var canSend: Bool {
        let textNotEmpty = !messageViewModel.currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return isAIChatEnabled
            ? textNotEmpty && !messageViewModel.isBotTyping
            : textNotEmpty
    }
}

struct MessageRow: View {
    let message: Message

    var body: some View {
        HStack {
            switch message.senderType {
            case "user":
                Spacer()
                Text(message.message)
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
            case "admin":
                HStack {
                    Image(systemName: "person.crop.circle.fill.badge.checkmark")
                        .foregroundColor(.orange)
                    Text(message.message)
                        .padding(10)
                        .background(Color(.systemYellow).opacity(0.2))
                        .foregroundColor(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                Spacer()
            default: // AI
                Text(message.message)
                    .padding(10)
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                Spacer()
            }
        }
    }
}
