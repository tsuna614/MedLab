//
//  SnackBarView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 18/4/25.
//

import SwiftUI

//struct SnackbarView: View {
//    let message: String
//    let action: (() -> Void)?
//    let onDismiss: () -> Void
//
//    @State private var isShowing = true
//
//    var body: some View {
//        HStack {
//            Text(message)
//                .foregroundColor(.white)
//            Spacer()
//            if let action = action {
//                Button("Action") {
//                    action()
//                    dismiss()
//                }
//                .foregroundColor(.yellow)
//            }
//        }
//        .padding()
//        .background(Color.black.opacity(0.8))
//        .cornerRadius(8)
//        .padding(.horizontal)
//        .padding(.bottom, 50)
//        .opacity(isShowing ? 1 : 0)
//        .onTapGesture {
//            dismiss()
//        }
//    }
//
//    private func dismiss() {
//         withAnimation(.easeOut(duration: 0.3)) {
//            isShowing = false
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
//            onDismiss()
//        }
//    }
//}

struct SnackbarView: View {
    var message: String

    var body: some View {
        Text(message)
            .padding()
            .background(Color.black.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal, 20)
            .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
