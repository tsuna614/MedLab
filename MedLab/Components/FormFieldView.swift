//
//  FormFieldView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 14/5/25.
//

import SwiftUI

struct FormFieldView: View {
    let iconName: String
    let title: String
    @Binding var text: String
    var prompt: String? = nil
    var keyboardType: UIKeyboardType
    var textContentType: UITextContentType? = nil
    var isSecure: Bool
    
    var isEditable: Bool
    
    init(
        iconName: String,
        title: String,
        text: Binding<String>,
        prompt: String? = nil,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        isSecure: Bool = false,
        isEditable: Bool = true
    ) {
        self.iconName = iconName
        self.title = title
        self._text = text
        self.prompt = prompt
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        self.isSecure = isSecure
        self.isEditable = isEditable
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption) // Smaller font for the title
                .foregroundColor(.secondary) // Subdued color
            
            HStack(spacing: 10) {
                Image(systemName: iconName)
                    .foregroundColor(.gray)
                    .frame(width: 20, alignment: .center)

                Group {
                    if isSecure {
                        SecureField(prompt ?? title, text: $text)
                    } else {
                        TextField(prompt ?? title, text: $text)
                        
                    }
                }
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .disabled(!isEditable) // Use the isEditable property to disable
                .opacity(isEditable ? 1.0 : 0.4)
            }
//            .padding(10)
//            .background(Color(.systemGray6))
//            .cornerRadius(8)
        }
        .padding(.horizontal, 10)
    }
}
