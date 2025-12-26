//
//  RecordingRecord.swift
//  echoes
//
//  Created by AI Assistant on 26/12/2025.
//

import Foundation

struct RecordingRecord: Codable, Identifiable {
    let id: String // UUID as string
    let fileName: String
    let storagePath: String // Path in Firebase Storage
    let duration: TimeInterval
    let status: RecordingStatus
    let createdAt: String // ISO8601 formatted date
    let downloadURL: String? // Firebase Storage download URL
    
    enum RecordingStatus: String, Codable, CaseIterable {
        case incomplete = "incomplete"
        case uploading = "uploading"
        case complete = "complete"
        case failed = "failed"
    }
    
    init(id: UUID, fileName: String, storagePath: String, duration: TimeInterval, status: RecordingStatus = .incomplete, createdAt: Date = Date(), downloadURL: String? = nil) {
        self.id = id.uuidString
        self.fileName = fileName
        self.storagePath = storagePath
        self.duration = duration
        self.status = status
        
        let formatter = ISO8601DateFormatter()
        self.createdAt = formatter.string(from: createdAt)
        self.downloadURL = downloadURL
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var createdAtDate: Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: createdAt)
    }
    
    var formattedDate: String {
        guard let date = createdAtDate else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var statusDisplayText: String {
        switch status {
        case .incomplete:
            return "Processing"
        case .uploading:
            return "Uploading"
        case .complete:
            return "Ready"
        case .failed:
            return "Failed"
        }
    }
}