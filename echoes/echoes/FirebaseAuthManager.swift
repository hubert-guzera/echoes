//
//  FirebaseAuthManager.swift
//  echoes
//
//  Created by Hubert Guzera on 30/10/2025.
//

import Foundation
import FirebaseAuth
import Combine

class FirebaseAuthManager: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        listenToAuthState()
    }
    
    private func listenToAuthState() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    let nsError = error as NSError
                    print("Sign In Error: \(nsError.localizedDescription)")
                    print("Error Code: \(nsError.code)")
                    print("Error Domain: \(nsError.domain)")
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                } else {
                    self?.errorMessage = nil
                    completion(.success(()))
                }
            }
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                } else {
                    self?.errorMessage = nil
                    completion(.success(()))
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}

