//
//  PrimaryButton.swift
//  echoes
//
//  Created by Hubert Guzera on 30/10/2025.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isDisabled ? Color.gray : Color.appPrimary)
            .cornerRadius(12)
        }
        .disabled(isDisabled || isLoading)
    }
}
