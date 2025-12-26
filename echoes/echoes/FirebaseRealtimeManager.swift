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
    
    // Published properties for recordings to enable real-time updates
    @Published var recordingRecords: [RecordingRecord] = []
    @Published var isLoadingRecordings = false
    @Published var recordingError: String?
    
    private var database: DatabaseReference
    private var profileListener: DatabaseHandle?
    private var recordingsListener: DatabaseHandle?
    
    init() {
        // Use the Europe West 1 database URL
        let databaseURL = "https://kotalojz-echoes-default-rtdb.europe-west1.firebasedatabase.app"
        database = Database.database(url: databaseURL).reference()
    }
    
    deinit {
        removeProfileListener()
        removeRecordingsListener()
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
    
    /// Creates sample recording record for testing purposes
    func createSampleRecordingRecord() async throws {
        let sampleRecord = RecordingRecord(
            id: UUID(),
            fileName: "sample_recording.m4a",
            storagePath: "users/sample/sample_recording.m4a",
            duration: 45.5,
            status: .incomplete // Note: should be incomplete for post-processing
        )
        
        try await createRecordingRecord(sampleRecord)
    }
    
    // MARK: - Recording Management
    
    func createRecordingRecord(_ record: RecordingRecord) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseRealtimeError.noAuthenticatedUser
        }
        
        let recordingPath = "users/\(currentUser.uid)/recordings/\(record.id)"
        let recordingRef = database.child(recordingPath)
        
        do {
            let recordData = try JSONEncoder().encode(record)
            let recordDict = try JSONSerialization.jsonObject(with: recordData) as? [String: Any]
            
            return try await withCheckedThrowingContinuation { continuation in
                recordingRef.setValue(recordDict) { error, _ in
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
    
    func updateRecordingStatus(_ recordId: String, status: RecordingRecord.RecordingStatus) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseRealtimeError.noAuthenticatedUser
        }
        
        let recordingPath = "users/\(currentUser.uid)/recordings/\(recordId)"
        let recordingRef = database.child(recordingPath)
        
        let updates: [String: Any] = ["status": status.rawValue]
        
        return try await withCheckedThrowingContinuation { continuation in
            recordingRef.updateChildValues(updates) { error, _ in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func getAllRecordingRecords() async throws -> [RecordingRecord] {
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseRealtimeError.noAuthenticatedUser
        }
        
        let recordingsPath = "users/\(currentUser.uid)/recordings"
        let recordingsRef = database.child(recordingsPath)
        
        return try await withCheckedThrowingContinuation { continuation in
            recordingsRef.observeSingleEvent(of: .value) { snapshot in
                var records: [RecordingRecord] = []
                
                if snapshot.exists() {
                    for child in snapshot.children {
                        if let childSnapshot = child as? DataSnapshot,
                           let value = childSnapshot.value,
                           let jsonData = try? JSONSerialization.data(withJSONObject: value),
                           let record = try? JSONDecoder().decode(RecordingRecord.self, from: jsonData) {
                            records.append(record)
                        }
                    }
                }
                
                // Sort by creation date, newest first
                records.sort { record1, record2 in
                    guard let date1 = record1.createdAtDate, let date2 = record2.createdAtDate else {
                        return false
                    }
                    return date1 > date2
                }
                
                continuation.resume(returning: records)
            } withCancel: { error in
                continuation.resume(throwing: error)
            }
        }
    }
    
    func deleteRecordingRecord(_ recordId: String) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw FirebaseRealtimeError.noAuthenticatedUser
        }
        
        let recordingPath = "users/\(currentUser.uid)/recordings/\(recordId)"
        let recordingRef = database.child(recordingPath)
        
        return try await withCheckedThrowingContinuation { continuation in
            recordingRef.removeValue { error, _ in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func removeProfileListener() {
        if let listener = profileListener {
            database.removeObserver(withHandle: listener)
            profileListener = nil
        }
    }
    
    private func removeRecordingsListener() {
        if let listener = recordingsListener {
            database.removeObserver(withHandle: listener)
            recordingsListener = nil
        }
    }
    
    // MARK: - Real-time Recordings Listener
    
    func startListeningToRecordings() {
        guard let currentUser = Auth.auth().currentUser else {
            recordingError = "No authenticated user found"
            return
        }
        
        removeRecordingsListener()
        
        let recordingsPath = "users/\(currentUser.uid)/recordings"
        let recordingsRef = database.child(recordingsPath)
        
        isLoadingRecordings = true
        recordingError = nil
        
        recordingsListener = recordingsRef.observe(.value) { [weak self] snapshot in
            DispatchQueue.main.async {
                self?.isLoadingRecordings = false
                
                var records: [RecordingRecord] = []
                
                if snapshot.exists() {
                    print("📊 Database snapshot exists with \(snapshot.childrenCount) children")
                    
                    for child in snapshot.children {
                        if let childSnapshot = child as? DataSnapshot,
                           let value = childSnapshot.value {
                            
                            print("🔍 Processing child: \(childSnapshot.key)")
                            print("📄 Raw data: \(value)")
                            
                            do {
                                let jsonData = try JSONSerialization.data(withJSONObject: value)
                                let record = try JSONDecoder().decode(RecordingRecord.self, from: jsonData)
                                records.append(record)
                                print("✅ Successfully decoded: \(record.fileName)")
                            } catch {
                                print("❌ Failed to decode record \(childSnapshot.key): \(error)")
                                print("📄 Problematic data: \(value)")
                            }
                        }
                    }
                } else {
                    print("📊 No recordings found in database")
                }
                
                // Sort by creation date, newest first
                records.sort { record1, record2 in
                    guard let date1 = record1.createdAtDate, let date2 = record2.createdAtDate else {
                        return false
                    }
                    return date1 > date2
                }
                
                self?.recordingRecords = records
                self?.recordingError = nil
                print("🔄 Real-time update: \(records.count) recordings loaded")
            }
        } withCancel: { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoadingRecordings = false
                self?.recordingError = "Database error: \(error.localizedDescription)"
                print("❌ Firebase recordings listener error: \(error)")
            }
        }
    }
    
    func stopListeningToRecordings() {
        removeRecordingsListener()
        recordingRecords = []
        recordingError = nil
        isLoadingRecordings = false
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