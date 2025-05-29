//
//  MessageView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 30/3/25.
//

import SwiftUI

struct MessageView: View {
    @StateObject private var viewModel: MessageViewModel

    init() {
        let messageServiceInstance = MessageService(apiClient: ApiClient(baseURLString: base_url))
        _viewModel = StateObject(wrappedValue: MessageViewModel(messageService: messageServiceInstance))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                contentView
                botTypingIndicator
                inputArea
            }
            .navigationTitle("AI Doctor Chat")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), actions: {
                Button("OK") { viewModel.errorMessage = nil }
            }) {
                Text(viewModel.errorMessage ?? "An unknown error occurred.")
            }
            .onAppear {
                Task {
                    await viewModel.loadChatHistory()
                }
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoadingHistory && viewModel.messages.isEmpty {
            ProgressView("Loading history...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if !viewModel.isLoadingHistory && viewModel.messages.isEmpty && viewModel.errorMessage == nil {
            emptyStateView
        } else {
            messageListView
        }
    }

    private var emptyStateView: some View {
        VStack {
            Spacer()
            Image(systemName: "message.badge.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No Messages Yet")
                .font(.title2)
            Text("Start a conversation with the AI Doctor.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var messageListView: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView(.vertical) {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MessageRow(message: message)
                            .id(message.id)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .onChange(of: viewModel.messages.count) {
                if let lastMessage = viewModel.messages.last {
                    withAnimation(.easeOut(duration: 0.25)) {
                        scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            .onAppear {
                 if let lastMessage = viewModel.messages.last {
                      scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                 }
            }
        }
    }

    @ViewBuilder
    private var botTypingIndicator: some View {
        if viewModel.isBotTyping {
            HStack {
                ProgressView().scaleEffect(0.7)
                Text("AI Doctor is typing...").font(.caption).foregroundColor(.secondary)
                Spacer()
            }
            .padding([.horizontal, .top], 10)
            .padding(.bottom, 5)
        }
    }

    private var inputArea: some View {
        HStack(spacing: 10) {
            TextField("Ask the AI Doctor...", text: $viewModel.currentInput, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .lineLimit(1...5)

            Button {
                viewModel.sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title)
                    .foregroundColor(viewModel.currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isBotTyping ? .gray : .blue)
            }
            .disabled(viewModel.currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isBotTyping)
        }
        .padding()
        .background(.thinMaterial)
    }
}

struct MessageRow: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.senderType == "user" {
                Spacer()
                Text(message.message)
                    .padding(10).background(Color.blue).foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
            } else {
                Text(message.message)
                    .padding(10).background(Color(.systemGray5)).foregroundColor(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                Spacer()
            }
        }
    }
}
