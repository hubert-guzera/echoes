//
//  CloudRecordingCard.swift
//  echoes
//
//  Created by AI Assistant on 26/12/2025.
//

import SwiftUI

struct CloudRecordingCard: View {
    let recording: RecordingRecord
    let onViewDetails: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    // Date and Status Row
                    HStack {
                        Text(recording.formattedDate)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                        
                        Spacer()
                        
                        // Status Indicator
                        HStack(spacing: 4) {
                            statusIcon
                            Text(recording.statusDisplayText)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(statusColor)
                        }
                    }
                    
                    // Duration
                    Text(recording.formattedDuration)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                    
                    // File name (truncated)
                    Text(recording.fileName)
                        .font(.system(size: 13))
                        .foregroundColor(.appTextSecondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    // View Details Button
                    Button(action: onViewDetails) {
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(Color.appPrimary.opacity(0.15))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 18))
                                    .foregroundColor(.appPrimary)
                            }
                            
                            Text("Details")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.appTextSecondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Delete Button
                    Button(action: onDelete) {
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(Color.appError.opacity(0.1))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.appError)
                            }
                            
                            Text("Delete")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.appError)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(20)
        .background(Color.appCardBackground)
        .cornerRadius(16)
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

#Preview {
    VStack(spacing: 16) {
        CloudRecordingCard(
            recording: RecordingRecord(
                id: UUID(),
                fileName: "sample_recording_with_very_long_name.m4a",
                storagePath: "users/test/sample.m4a",
                duration: 120.5,
                status: .complete
            ),
            onViewDetails: {},
            onDelete: {}
        )
        
        CloudRecordingCard(
            recording: RecordingRecord(
                id: UUID(),
                fileName: "processing_recording.m4a",
                storagePath: "users/test/processing.m4a",
                duration: 45.2,
                status: .incomplete
            ),
            onViewDetails: {},
            onDelete: {}
        )
        
        CloudRecordingCard(
            recording: RecordingRecord(
                id: UUID(),
                fileName: "uploading_recording.m4a",
                storagePath: "users/test/uploading.m4a",
                duration: 75.8,
                status: .uploading
            ),
            onViewDetails: {},
            onDelete: {}
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}