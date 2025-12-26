//
//  RecordingDetailsView.swift
//  echoes
//
//  Created by AI Assistant on 26/12/2025.
//

import SwiftUI

struct RecordingDetailsView: View {
    let recording: RecordingRecord
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var realtimeManager: FirebaseRealtimeManager
    @State private var showingDeleteAlert = false
    @State private var isDeleting = false
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Recording Info Header
                    VStack(alignment: .leading, spacing: 16) {
                        // Title and Status
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Recording Details")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.appTextPrimary)
                                
                                HStack(spacing: 8) {
                                    statusIcon
                                    Text(recording.statusDisplayText)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(statusColor)
                                }
                            }
                            
                            Spacer()
                        }
                        
                        // Recording Metadata
                        VStack(spacing: 12) {
                            InfoRow(label: "Duration", value: recording.formattedDuration)
                            InfoRow(label: "Created", value: recording.formattedDate)
                            InfoRow(label: "File Name", value: recording.fileName)
                            InfoRow(label: "Storage Path", value: recording.storagePath)
                        }
                    }
                    .padding(20)
                    .background(Color.appCardBackground)
                    .cornerRadius(16)
                    
                    // Transcription Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Transcription")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.appTextPrimary)
                            
                            Spacer()
                        }
                        
                        if recording.status != .complete && recording.status != .completed {
                            // Show message for incomplete recordings
                            VStack(spacing: 12) {
                                Image(systemName: "doc.text.below.ecg")
                                    .font(.system(size: 40))
                                    .foregroundColor(.appTextSecondary)
                                
                                Text("Transcription Not Available")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.appTextPrimary)
                                
                                Text("The recording must be fully processed before transcription is available.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.appTextSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                            
                        } else if let transcription = recording.transcription, !transcription.isEmpty {
                            // Show transcription from database
                            ScrollView {
                                Text(transcription)
                                    .font(.system(size: 16))
                                    .foregroundColor(.appTextPrimary)
                                    .lineSpacing(4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color.appBackground)
                                    .cornerRadius(12)
                            }
                            .frame(maxHeight: 300)
                            
                        } else {
                            // No transcription available
                            VStack(spacing: 12) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 40))
                                    .foregroundColor(.appTextSecondary)
                                
                                Text("No Transcription")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.appTextPrimary)
                                
                                Text("This recording doesn't have a transcription yet. Check back later as it may still be processing.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.appTextSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        }
                    }
                    .padding(20)
                    .background(Color.appCardBackground)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Recording Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Delete") {
                    showingDeleteAlert = true
                }
                .foregroundColor(.appError)
                .disabled(isDeleting)
            }
        }
        .alert("Delete Recording", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteRecording()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone. The recording and its transcription will be permanently deleted.")
        }
    }
    
    // MARK: - Actions
    
    private func deleteRecording() {
        isDeleting = true
        
        Task {
            do {
                try await realtimeManager.deleteRecordingRecord(recording.id)
                print("✅ Deleted recording: \(recording.fileName)")
                
                DispatchQueue.main.async {
                    self.dismiss()
                }
            } catch {
                print("❌ Failed to delete recording: \(error)")
                DispatchQueue.main.async {
                    self.isDeleting = false
                    // Could show an error alert here if needed
                }
            }
        }
    }
    
    // MARK: - Status Styling
    
    private var statusIcon: Image {
        switch recording.status {
        case .incomplete:
            return Image(systemName: "clock.fill")
        case .uploading:
            return Image(systemName: "icloud.and.arrow.up.fill")
        case .complete, .completed:
            return Image(systemName: "checkmark.circle.fill")
        case .failed:
            return Image(systemName: "exclamationmark.triangle.fill")
        }
    }
    
    private var statusColor: Color {
        switch recording.status {
        case .incomplete:
            return .orange
        case .uploading:
            return .blue
        case .complete, .completed:
            return .green
        case .failed:
            return .red
        }
    }
}

// MARK: - Supporting Views

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appTextSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(.appTextPrimary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }
}

#Preview {
    RecordingDetailsView(
        recording: RecordingRecord(
            id: UUID(),
            fileName: "sample_recording.m4a",
            storagePath: "users/test/sample.m4a",
            duration: 120.5,
            status: .complete,
            transcription: "This is a sample transcription of the recording. It demonstrates how the transcription text would appear in the user interface with proper formatting and readability."
        )
    )
    .environmentObject(FirebaseRealtimeManager())
}