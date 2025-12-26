//
//  LoginView.swift
//  echoes
//
//  Created by Hubert Guzera on 30/10/2025.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var authManager: FirebaseAuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showSignUp = false
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Echoes")
                        .font(.system(size: 48, weight: .black))
                        .foregroundColor(.appTextPrimary)
                    Text("Welcome Back")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(.appTextPlaceholder)
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 50)
                
                // Login Form
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
                    
                    // Error Message
                    if let errorMessage = authManager.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.appError)
                            .padding(.top, 8)
                    }
                    
                    // Login Button
                    PrimaryButton(
                        title: "Sign In",
                        isLoading: isLoading,
                        action: {
                            isLoading = true
                            authManager.signIn(email: email, password: password) { result in
                                isLoading = false
                            }
                        },
                        isDisabled: email.isEmpty || password.isEmpty
                    )
                    .padding(.top, 8)
                    
                    // Sign Up Link
                    HStack {
                        Text("Don't have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(.appTextSecondary)
                        
                        Button(action: {
                            showSignUp = true
                        }) {
                            Text("Sign Up")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.appPrimary)
                        }
                    }
                    .padding(.top, 16)
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView(authManager: authManager, isPresented: $showSignUp)
        }
    }
}


