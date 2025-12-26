//
//  Color+Extensions.swift
//  echoes
//
//  Created by Hubert Guzera on 30/10/2025.
//

import SwiftUI

extension Color {
    static let appBackground = Color(red: 200/255, green: 213/255, blue: 208/255)
    static let appPrimary = Color(red: 1.0, green: 0.8, blue: 0.0)
    static let appTextPrimary = Color.primary
    // Improved accessibility: Darker secondary text for better contrast
    static let appTextSecondary = Color(red: 0.3, green: 0.3, blue: 0.3)
    // Improved placeholder text contrast
    static let appTextPlaceholder = Color(red: 0.5, green: 0.5, blue: 0.5)
    static let appInputBackground = Color.white.opacity(0.8)
    // More vibrant system red for destructive actions
    static let appError = Color(.systemRed)
    static let appCardBackground = Color.white.opacity(0.6)
    static let appCardBackgroundSecondary = Color.white.opacity(0.4)
}
