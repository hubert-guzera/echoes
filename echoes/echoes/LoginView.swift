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
            Color(red: 200/255, green: 213/255, blue: 208/255)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Echoes")
                        .font(.system(size: 48, weight: .black))
                        .foregroundColor(.primary)
                    Text("Welcome Back")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(.gray.opacity(0.4))
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 50)
                
                // Login Form
                VStack(spacing: 20) {
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 16))
                            .padding(16)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(12)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                        
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 16))
                            .padding(16)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(12)
                    }
                    
                    // Error Message
                    if let errorMessage = authManager.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .padding(.top, 8)
                    }
                    
                    // Login Button
                    Button(action: {
                        isLoading = true
                        authManager.signIn(email: email, password: password) { result in
                            isLoading = false
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign In")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(email.isEmpty || password.isEmpty ? Color.gray : Color(red: 1.0, green: 0.8, blue: 0.0))
                        .cornerRadius(12)
                    }
                    .disabled(email.isEmpty || password.isEmpty || isLoading)
                    .padding(.top, 8)
                    
                    // Sign Up Link
                    HStack {
                        Text("Don't have an account?")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            showSignUp = true
                        }) {
                            Text("Sign Up")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.0))
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

