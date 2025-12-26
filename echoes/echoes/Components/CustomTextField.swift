//
//  CustomTextField.swift
//  echoes
//
//  Created by Hubert Guzera on 30/10/2025.
//

import SwiftUI

struct CustomTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: UITextAutocapitalizationType = .sentences
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appTextSecondary)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 16))
                    .padding(16)
                    .background(Color.appInputBackground)
                    .cornerRadius(12)
                    .accessibilityLabel(title)
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 16))
                    .padding(16)
                    .background(Color.appInputBackground)
                    .cornerRadius(12)
                    .autocapitalization(autocapitalization)
                    .keyboardType(keyboardType)
                    .accessibilityLabel(title)
            }
        }
    }
}
