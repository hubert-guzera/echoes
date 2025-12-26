//
//  RecordingDetailsView.swift
//  echoes
//
//  Created by AI Assistant on 26/12/2025.
//

import SwiftUI

struct RecordingDetailsView: View {
    let recording: RecordingRecord
    @Environment(\.presentationMode) var presentationMode
    @State private var transcription: String = ""
    @State private var isLoadingTranscription = false
    @State private var transcriptionError: String?
    
    var body: some View {
        NavigationView {
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
                                
                                if recording.status == .complete || recording.status == .completed {
                                    Button("Refresh") {
                                        loadTranscription()
                                    }
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.appPrimary)
                                }
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
                                
                            } else if isLoadingTranscription {
                                // Loading state
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Loading transcription...")
                                        .font(.system(size: 14))
                                        .foregroundColor(.appTextSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                
                            } else if let error = transcriptionError {
                                // Error state
                                VStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .font(.system(size: 40))
                                        .foregroundColor(.appError)
                                    
                                    Text("Transcription Error")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.appError)
                                    
                                    Text(error)
                                        .font(.system(size: 14))
                                        .foregroundColor(.appTextSecondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                
                            } else if transcription.isEmpty {
                                // No transcription available
                                VStack(spacing: 12) {
                                    Image(systemName: "doc.text")
                                        .font(.system(size: 40))
                                        .foregroundColor(.appTextSecondary)
                                    
                                    Text("No Transcription")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.appTextPrimary)
                                    
                                    Text("This recording doesn't have a transcription yet.")
                                        .font(.system(size: 14))
                                        .foregroundColor(.appTextSecondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                
                            } else {
                                // Show transcription
                                Text(transcription)
                                    .font(.system(size: 16))
                                    .foregroundColor(.appTextPrimary)
                                    .lineSpacing(4)
                                    .padding()
                                    .background(Color.appBackground)
                                    .cornerRadius(12)
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.appPrimary)
                }
            }
        }
        .onAppear {
            if recording.status == .complete || recording.status == .completed {
                loadTranscription()
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
    
    // MARK: - Data Loading
    
    private func loadTranscription() {
        isLoadingTranscription = true
        transcriptionError = nil
        
        // TODO: Replace with actual transcription loading from your backend
        // For now, simulate loading with placeholder data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoadingTranscription = false
            
            // Mock transcription data - replace with actual API call
            if recording.status == .complete || recording.status == .completed {
                transcription = """
                This is a placeholder transcription for the recording "\(recording.fileName)".
                
                In a real implementation, you would:
                1. Make an API call to your transcription service
                2. Pass the recording ID or storage path
                3. Display the actual transcribed text
                4. Handle any errors appropriately
                
                The recording was created on \(recording.formattedDate) and has a duration of \(recording.formattedDuration).
                """
            } else {
                transcriptionError = "Recording is not yet complete"
            }
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
            status: .complete
        )
    )
}