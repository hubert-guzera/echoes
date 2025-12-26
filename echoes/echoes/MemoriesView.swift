//
//  MemoriesView.swift
//  echoes
//
//  Created by Hubert Guzera on 30/10/2025.
//

import SwiftUI

struct MemoriesView: View {
    @ObservedObject var audioManager: AudioRecorderManager
    @EnvironmentObject var authManager: FirebaseAuthManager
    @StateObject private var realtimeManager = FirebaseRealtimeManager()
    @State private var showingRecordingDetails = false
    @State private var selectedRecording: RecordingRecord?
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your")
                        .font(.system(size: 48, weight: .black))
                        .foregroundColor(.appTextPrimary)
                    Text("Memories")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(.appTextPlaceholder)
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 30)
                
                // Content
                if realtimeManager.isLoadingRecordings {
                    // Loading State
                    VStack(spacing: 24) {
                        Spacer()
                        
                        ProgressView()
                            .scaleEffect(1.5)
                            .foregroundColor(.appPrimary)
                        
                        Text("Loading memories...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    
                } else if let errorMessage = realtimeManager.recordingError {
                    // Error State
                    VStack(spacing: 24) {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(Color.appError.opacity(0.1))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.appError)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Error Loading Memories")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.appTextPrimary)
                            
                            Text(errorMessage)
                                .font(.system(size: 16))
                                .foregroundColor(.appTextSecondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        
                        Button("Try Again") {
                            realtimeManager.startListeningToRecordings()
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.appPrimary)
                        .padding(.top, 8)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                    
                } else if realtimeManager.recordingRecords.isEmpty {
                    // Empty State
                    VStack(spacing: 24) {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(Color.appPrimary.opacity(0.1))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "waveform.circle")
                                .font(.system(size: 50))
                                .foregroundColor(.appPrimary)
                        }
                        
                        VStack(spacing: 8) {
                            Text("No Memories Yet")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.appTextPrimary)
                            
                            Text("You haven't captured any echoes yet.\nTap the Recording tab to start.")
                                .font(.system(size: 16))
                                .foregroundColor(.appTextSecondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                    
                } else {
                    // Recordings List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(realtimeManager.recordingRecords) { recording in
                                CloudRecordingCard(
                                    recording: recording,
                                    onViewDetails: {
                                        selectedRecording = recording
                                        showingRecordingDetails = true
                                    },
                                    onDelete: {
                                        deleteRecording(recording)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .refreshable {
                        realtimeManager.startListeningToRecordings()
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            if authManager.isAuthenticated {
                realtimeManager.startListeningToRecordings()
            }
        }
        .onChange(of: authManager.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated {
                realtimeManager.startListeningToRecordings()
            } else {
                realtimeManager.stopListeningToRecordings()
            }
        }
        .sheet(isPresented: $showingRecordingDetails) {
            if let recording = selectedRecording {
                RecordingDetailsView(recording: recording)
            }
        }
        // Refresh when app comes back to foreground
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if authManager.isAuthenticated {
                realtimeManager.startListeningToRecordings()
            }
        }
    }
    
    // MARK: - Cloud Data Functions
    
    private func deleteRecording(_ recording: RecordingRecord) {
        Task {
            do {
                try await realtimeManager.deleteRecordingRecord(recording.id)
                print("✅ Deleted recording: \(recording.fileName)")
                // No need to manually update UI - real-time listener will handle it
            } catch {
                print("❌ Failed to delete recording: \(error)")
                // Could show an alert here if needed
            }
        }
    }
}

#Preview {
    MemoriesView(audioManager: AudioRecorderManager())
        .environmentObject(FirebaseAuthManager())
}
