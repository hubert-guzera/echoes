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
    // Note: downloadURL removed - not stored in database, only used locally
    // Note: transcription field is ignored during decoding
    
    enum RecordingStatus: String, Codable, CaseIterable {
        case incomplete = "incomplete" // Default - needs post-processing
        case uploading = "uploading"   // File is being uploaded to storage
        case complete = "complete"     // Post-processing finished
        case completed = "completed"   // Alternative spelling for backward compatibility
        case failed = "failed"         // Upload or processing failed
    }
    
    init(id: UUID, fileName: String, storagePath: String, duration: TimeInterval, status: RecordingStatus = .incomplete, createdAt: Date = Date()) {
        self.id = id.uuidString
        self.fileName = fileName
        self.storagePath = storagePath
        self.duration = duration
        self.status = status == .completed ? .complete : status // Normalize completed to complete
        
        let formatter = ISO8601DateFormatter()
        self.createdAt = formatter.string(from: createdAt)
    }
    
    // Custom decoder to handle flexible field parsing
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.fileName = try container.decode(String.self, forKey: .fileName)
        self.storagePath = try container.decode(String.self, forKey: .storagePath)
        
        // Handle duration as either string or double
        if let durationString = try? container.decode(String.self, forKey: .duration),
           let durationValue = TimeInterval(durationString) {
            self.duration = durationValue
        } else {
            self.duration = try container.decode(TimeInterval.self, forKey: .duration)
        }
        
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        
        // Handle status with backward compatibility for "completed"
        let statusString = try container.decode(String.self, forKey: .status)
        if statusString == "completed" {
            self.status = .complete
        } else {
            self.status = RecordingStatus(rawValue: statusString) ?? .incomplete
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, fileName, storagePath, duration, status, createdAt
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
        case .complete, .completed:
            return "Ready"
        case .failed:
            return "Failed"
        }
    }
}