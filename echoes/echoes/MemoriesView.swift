//
//  MemoriesView.swift
//  echoes
//
//  Created by Hubert Guzera on 30/10/2025.
//

import SwiftUI

struct MemoriesView: View {
    @ObservedObject var audioManager: AudioRecorderManager
    @State private var selectedDate = Date()
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your")
                        .font(.system(size: 48, weight: .black))
                        .foregroundColor(.appTextPrimary)
                    Text("Memories")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(.appTextPlaceholder)
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 30)
                
                // Recordings List
                ScrollView {
                    if audioManager.recordings.isEmpty {
                        VStack(spacing: 24) {
                            Spacer()
                            
                            // Improved empty state icon
                            ZStack {
                                Circle()
                                    .fill(Color.appPrimary.opacity(0.1))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "waveform.circle")
                                    .font(.system(size: 50))
                                    .foregroundColor(.appPrimary)
                            }
                            
                            VStack(spacing: 8) {
                                Text("No Memories Yet")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.appTextPrimary)
                                
                                Text("You haven't captured any echoes yet.\nTap the Recording tab to start.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.appTextSecondary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                            }
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(audioManager.recordings) { recording in
                                RecordingCard(
                                    recording: recording,
                                    isPlaying: audioManager.currentPlayingId == recording.id && audioManager.isPlaying,
                                    playbackTime: audioManager.currentPlayingId == recording.id ? audioManager.playbackTime : 0,
                                    onPlay: {
                                        audioManager.playRecording(recording)
                                    },
                                    onDelete: {
                                        audioManager.deleteRecording(recording)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    MemoriesView(audioManager: AudioRecorderManager())
}
