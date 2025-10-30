//
//  ContentView.swift
//  kotalojz
//
//  Created by Hubert Guzera on 30/10/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var audioManager = AudioRecorderManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Recording Section
                VStack(spacing: 15) {
                    if audioManager.isRecording {
                        Text("Recording...")
                            .font(.title2)
                            .foregroundColor(.red)
                        
                        Text(formatTime(audioManager.recordingTime))
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundColor(.red)
                    } else {
                        Text("Ready to Record")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        if audioManager.isRecording {
                            audioManager.stopRecording()
                        } else {
                            audioManager.startRecording()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(audioManager.isRecording ? Color.red : Color.blue)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: audioManager.isRecording ? "stop.fill" : "mic.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.vertical, 20)
                
                Divider()
                
                // Recordings List Section
                if audioManager.recordings.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "waveform")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No recordings yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Tap the microphone to start recording")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(audioManager.recordings) { recording in
                            RecordingRow(
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
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Voice Recorder")
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%01d", minutes, seconds, milliseconds)
    }
}

struct RecordingRow: View {
    let recording: Recording
    let isPlaying: Bool
    let playbackTime: TimeInterval
    let onPlay: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            Button(action: onPlay) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recording.formattedDate)
                    .font(.headline)
                
                HStack {
                    if isPlaying {
                        Text(formatPlaybackTime(playbackTime))
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text("/")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text(recording.formattedDuration)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if isPlaying {
                    ProgressView(value: playbackTime, total: recording.duration)
                        .progressViewStyle(LinearProgressViewStyle())
                }
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
    }
    
    private func formatPlaybackTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    ContentView()
}
