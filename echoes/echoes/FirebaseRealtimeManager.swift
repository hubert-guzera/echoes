//
//  FirebaseRealtimeManager.swift
//  echoes
//
//  Created by AI Assistant on 26/12/2025.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import Combine

class FirebaseRealtimeManager: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var database: DatabaseReference
    private var profileListener: DatabaseHandle?
    
    init() {
        // Use the Europe West 1 database URL
        let databaseURL = "https://kotalojz-echoes-default-rtdb.europe-west1.firebasedatabase.app"
        database = Database.database(url: databaseURL).reference()
    }
    
    deinit {
        removeProfileListener()
    }
    
    // MARK: - Public Methods
    
    func startListeningToUserProfile() {
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "No authenticated user found"
            return
        }
        
        removeProfileListener()
        
        let userProfilePath = "users/\(currentUser.uid)/profile"
        let profileRef = database.child(userProfilePath)
        
        isLoading = true
        errorMessage = nil
        
        // Listen for real-time updates
        profileListener = profileRef.observe(.value) { [weak self] snapshot in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if snapshot.exists() {
                    do {
                        // Convert snapshot to JSON data
                        guard let value = snapshot.value,
                              let jsonData = try? JSONSerialization.data(withJSONObject: value) else {
                            self?.errorMessage = "Failed to parse profile data"
                            return
                        }
                        
                        // Decode to UserProfile
                        let profile = try JSONDecoder().decode(UserProfile.self, from: jsonData)
                        self?.userProfile = profile
                        self?.errorMessage = nil
                        
                    } catch {
                        self?.errorMessage = "Failed to decode profile: \(error.localizedDescription)"
                        print("Profile decode error: \(error)")
                    }
                } else {
                    // No profile data exists
                    self?.userProfile = nil
                    self?.errorMessage = "No profile data found"
                }
            }
        } withCancel: { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.errorMessage = "Database error: \(error.localizedDescription)"
                print("Firebase Realtime Database error: \(error)")
            }
        }
    }
    
    func stopListeningToUserProfile() {
        removeProfileListener()
        userProfile = nil
        errorMessage = nil
        isLoading = false
    }
    
    func updateUserProfile(_ profile: UserProfile) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseRealtimeError.noAuthenticatedUser
        }
        
        let userProfilePath = "users/\(currentUser.uid)/profile"
        let profileRef = database.child(userProfilePath)
        
        do {
            let profileData = try JSONEncoder().encode(profile)
            let profileDict = try JSONSerialization.jsonObject(with: profileData) as? [String: Any]
            
            return try await withCheckedThrowingContinuation { continuation in
                profileRef.setValue(profileDict) { error, _ in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
            }
        } catch {
            throw FirebaseRealtimeError.encodingFailed(error)
        }
    }
    
    // MARK: - Development Helper
    
    /// Creates sample profile data for testing purposes
    func createSampleProfileData() async throws {
        let sampleProfile = UserProfile(
            age: 31,
            email: "john@example.com",
            lastLogin: "2025-12-26T10:00:00Z",
            name: "John Doe"
        )
        
        try await updateUserProfile(sampleProfile)
    }
    
    // MARK: - Private Methods
    
    private func removeProfileListener() {
        if let listener = profileListener {
            database.removeObserver(withHandle: listener)
            profileListener = nil
        }
    }
}

// MARK: - Error Types

enum FirebaseRealtimeError: LocalizedError {
    case noAuthenticatedUser
    case encodingFailed(Error)
    case decodingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .noAuthenticatedUser:
            return "No authenticated user found"
        case .encodingFailed(let error):
            return "Failed to encode data: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        }
    }
}