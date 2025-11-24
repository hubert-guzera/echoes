//
//  Recording.swift
//  kotalojz
//
//  Created by Hubert Guzera on 30/10/2025.
//

import Foundation

struct Recording: Identifiable, Codable {
    let id: UUID
    let fileName: String
    let date: Date
    let duration: TimeInterval
    let downloadURL: URL?
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    init(id: UUID = UUID(), fileName: String, date: Date = Date(), duration: TimeInterval = 0, downloadURL: URL? = nil) {
        self.id = id
        self.fileName = fileName
        self.date = date
        self.duration = duration
        self.downloadURL = downloadURL
    }
}

