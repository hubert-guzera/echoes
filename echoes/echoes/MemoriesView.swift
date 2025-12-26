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
                        VStack(spacing: 16) {
                            Spacer()
                            Image(systemName: "waveform.circle")
                                .font(.system(size: 70))
                                .foregroundColor(.gray.opacity(0.3))
                            Text("No recordings yet")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.gray)
                            Text("Tap Recording tab to start")
                                .font(.system(size: 14))
                                .foregroundColor(.gray.opacity(0.7))
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
