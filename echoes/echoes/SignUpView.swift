//
//  SignUpView.swift
//  echoes
//
//  Created by Hubert Guzera on 30/10/2025.
//

import SwiftUI

struct SignUpView: View {
    @ObservedObject var authManager: FirebaseAuthManager
    @Binding var isPresented: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.appTextPrimary)
                            .padding(12)
                            .background(Color.white.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Create")
                        .font(.system(size: 48, weight: .black))
                        .foregroundColor(.appTextPrimary)
                    Text("Account")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(.appTextPlaceholder)
                }
                .padding(.horizontal, 24)
                .padding(.top, 30)
                .padding(.bottom, 50)
                
                // Sign Up Form
                VStack(spacing: 20) {
                    // Email Field
                    CustomTextField(
                        title: "Email",
                        placeholder: "Enter your email",
                        text: $email,
                        keyboardType: .emailAddress,
                        autocapitalization: .none
                    )
                    
                    // Password Field
                    CustomTextField(
                        title: "Password",
                        placeholder: "Enter your password",
                        text: $password,
                        isSecure: true
                    )
                    
                    // Confirm Password Field
                    CustomTextField(
                        title: "Confirm Password",
                        placeholder: "Confirm your password",
                        text: $confirmPassword,
                        isSecure: true
                    )
                    
                    // Password Mismatch Warning
                    if !confirmPassword.isEmpty && password != confirmPassword {
                        Text("Passwords do not match")
                            .font(.system(size: 14))
                            .foregroundColor(.appError)
                    }
                    
                    // Error Message
                    if let errorMessage = authManager.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.appError)
                            .padding(.top, 8)
                    }
                    
                    // Sign Up Button
                    PrimaryButton(
                        title: "Sign Up",
                        isLoading: isLoading,
                        action: {
                            guard password == confirmPassword else { return }
                            isLoading = true
                            authManager.signUp(email: email, password: password) { result in
                                isLoading = false
                                if case .success = result {
                                    isPresented = false
                                }
                            }
                        },
                        isDisabled: !isFormValid
                    )
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }
}


