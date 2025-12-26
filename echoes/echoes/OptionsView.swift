//
//  OptionsView.swift
//  echoes
//
//  Created by Hubert Guzera on 26/12/2025.
//

import SwiftUI

struct OptionsView: View {
    @EnvironmentObject var authManager: FirebaseAuthManager
    @State private var recordingQuality = 0
    @State private var autoSave = true
    @State private var backgroundRecording = false
    
    let recordingQualities = ["Standard", "High", "Lossless"]
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("App")
                        .font(.system(size: 48, weight: .black))
                        .foregroundColor(.appTextPrimary)
                    Text("Settings")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(.appTextPlaceholder)
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 30)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Recording Quality Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recording Quality")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.appTextPrimary)
                            
                            Picker("Recording Quality", selection: $recordingQuality) {
                                ForEach(0..<recordingQualities.count, id: \.self) { index in
                                    Text(recordingQualities[index]).tag(index)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            // Quality descriptions
                            HStack {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 14))
                                    .foregroundColor(.appTextSecondary)
                                
                                Text(getQualityDescription())
                                    .font(.system(size: 13))
                                    .foregroundColor(.appTextSecondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(20)
                        .background(Color.appCardBackground)
                        .cornerRadius(16)
                        
                        // General Settings Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("General")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.appTextPrimary)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Auto-save recordings")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.appTextPrimary)
                                        Text("Automatically save when recording stops")
                                            .font(.system(size: 13))
                                            .foregroundColor(.appTextSecondary)
                                    }
                                    Spacer()
                                    Toggle("", isOn: $autoSave)
                                        .tint(.appPrimary)
                                }
                                
                                Divider()
                                    .background(Color.gray.opacity(0.2))
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Background recording")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.appTextPrimary)
                                        Text("Continue recording when app is minimized")
                                            .font(.system(size: 13))
                                            .foregroundColor(.appTextSecondary)
                                    }
                                    Spacer()
                                    Toggle("", isOn: $backgroundRecording)
                                        .tint(.appPrimary)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.appCardBackground)
                        .cornerRadius(16)
                        
                        // About Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("About")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.appTextPrimary)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Version")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.appTextPrimary)
                                    Spacer()
                                    Text("1.0.0")
                                        .font(.system(size: 16))
                                        .foregroundColor(.appTextSecondary)
                                }
                                
                                Divider()
                                    .background(Color.gray.opacity(0.2))
                                
                                HStack {
                                    Text("Privacy Policy")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.appTextPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.appTextSecondary)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    // Handle privacy policy
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.appCardBackground)
                        .cornerRadius(16)
                        
                        // Account Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Account")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.appTextPrimary)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Sign Out")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.appError)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.appTextSecondary)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    authManager.signOut()
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.appCardBackground)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
                
                Spacer()
            }
        }
    }
    
    private func getQualityDescription() -> String {
        switch recordingQuality {
        case 0:
            return "Standard quality (64 kbps) - Good for most recordings, smaller file size"
        case 1:
            return "High quality (128 kbps) - Better audio clarity, moderate file size"
        case 2:
            return "Lossless (ALAC) - Best quality, larger files. Uses ~10x more storage."
        default:
            return ""
        }
    }
}

#Preview {
    OptionsView()
        .environmentObject(FirebaseAuthManager())
}