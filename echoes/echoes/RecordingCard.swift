//
//  RecordingCard.swift
//  echoes
//
//  Created by Hubert Guzera on 26/12/2025.
//

import SwiftUI

struct RecordingCard: View {
    let recording: Recording
    let isPlaying: Bool
    let playbackTime: TimeInterval
    let onPlay: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(recording.formattedDate)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                    
                    Text(recording.formattedDuration)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                    
                    if isPlaying {
                        HStack(spacing: 4) {
                            Text(formatPlaybackTime(playbackTime))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.appPrimary)
                            Text("•")
                                .foregroundColor(.appTextPlaceholder)
                            Text("Playing")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.appTextSecondary)
                        }
                    }
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: onPlay) {
                        ZStack {
                            Circle()
                                .fill(isPlaying ? Color.appPrimary : Color.appTextSecondary.opacity(0.15))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 18))
                                .foregroundColor(isPlaying ? .black : .appTextPrimary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: onDelete) {
                        ZStack {
                            Circle()
                                .fill(Color.appError.opacity(0.1))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "trash.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.appError)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            if isPlaying {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.appTextSecondary.opacity(0.15))
                            .frame(height: 4)
                            .cornerRadius(2)
                        
                        Rectangle()
                            .fill(Color.appPrimary)
                            .frame(width: geometry.size.width * CGFloat(playbackTime / recording.duration), height: 4)
                            .cornerRadius(2)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(20)
        .background(Color.appCardBackground)
        .cornerRadius(16)
    }
    
    private func formatPlaybackTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    RecordingCard(
        recording: Recording(id: UUID(), fileName: "Sample Recording.m4a", date: Date(), duration: 60.0),
        isPlaying: false,
        playbackTime: 0,
        onPlay: {},
        onDelete: {}
    )
}