//
//  UserProfile.swift
//  echoes
//
//  Created by AI Assistant on 26/12/2025.
//

import Foundation

struct UserProfile: Codable, Equatable {
    let age: Int?
    let email: String?
    let lastLogin: String?
    let name: String?
    
    var displayName: String {
        return name ?? "Unknown User"
    }
    
    var displayEmail: String {
        return email ?? "No email"
    }
    
    var displayAge: String {
        if let age = age {
            return "\(age) years old"
        }
        return "Age not specified"
    }
    
    var lastLoginFormatted: String {
        guard let lastLogin = lastLogin else {
            return "Never logged in"
        }
        
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: lastLogin) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        
        return lastLogin
    }
}