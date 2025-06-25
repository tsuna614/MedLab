////
////  AdminMessageView.swift
////  MedLab
////
////  Created by Khanh Nguyen Quoc on 24/6/25.
////
//
//import SwiftUI
//
//struct MessageRequest: Codable {
//    let message: String
//    let senderType: String
//    var userId: String
//}
//
//struct AdminMessageView: View {
//    @StateObject private var webSocketService = WebSocketService(urlString: "ws://localhost:3000?id=67d50cecf6a282ef13412afb")
//    @State private var messageToSend = ""
//    
//    func convertToJSONRequest(message: String) -> MessageRequest {
//        return MessageRequest(message: message, senderType: "user", userId: "67d50cecf6a282ef13412afb")
//    }
//
//    var body: some View {
//        VStack {
//            Text("WebSocket Chat").font(.largeTitle).padding()
//
//            List(webSocketService.receivedMessages, id: \.self) { message in
//                Text(message)
//            }
//
//            HStack {
//                TextField("Enter message", text: $messageToSend)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                Button("Send") {
//                    webSocketService.send(message: convertToJSONRequest(message: messageToSend))
//                    messageToSend = ""
//                }
//            }.padding()
//
//            Button("Connect") {
//                webSocketService.connect()
//            }.padding()
//
//            Button("Disconnect") {
//                webSocketService.disconnect()
//            }.padding()
//        }
//        .onDisappear {
//            webSocketService.disconnect()
//        }
//    }
//}
//
//#Preview {
//    AdminMessageView()
//}
