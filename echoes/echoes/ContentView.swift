//
//  ContentView.swift
//  kotalojz
//
//  Created by Hubert Guzera on 30/10/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var audioManager = AudioRecorderManager()
    @EnvironmentObject var authManager: FirebaseAuthManager
    @State private var showRecordingScreen = false
    
    var body: some View {
        ZStack {
            Color(red: 200/255, green: 213/255, blue: 208/255)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Bold Hero Title Section
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Echoes")
                            .font(.system(size: 48, weight: .black))
                            .foregroundColor(.primary)
                        Text("Capturing ")
                            .font(.system(size: 36, weight: .black))
                            .foregroundColor(.gray.opacity(0.4))
                        Text("Memories")
                            .font(.system(size: 36, weight: .black))
                            .foregroundColor(.gray.opacity(0.4))
                    }
                    
                    Spacer()
                    
                    // Sign Out Button
                    Button(action: {
                        authManager.signOut()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding(12)
                            .background(Color.white.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 30)
                
                // Main Action Card
                Button(action: {
                    if !audioManager.isRecording {
                        audioManager.startRecording()
                        showRecordingScreen = true
                    }
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("New")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            Text("Recording")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(Color(red: 1.0, green: 0.8, blue: 0.0))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "mic.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 1.0, green: 0.8, blue: 0.0))
                    .cornerRadius(20)
                }
                .padding(.horizontal, 24)
                .buttonStyle(PlainButtonStyle())
                .fullScreenCover(isPresented: $showRecordingScreen) {
                    RecordingScreen(audioManager: audioManager, isPresented: $showRecordingScreen)
                }
                
                // Section Title
                if !audioManager.recordings.isEmpty {
                    Text("Recent Recordings")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                        .padding(.bottom, 12)
                }
                
                // Recordings Grid/List
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
                            Text("Tap above to start recording")
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
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%01d", minutes, seconds, milliseconds)
    }
}

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
                        .foregroundColor(.gray)
                    
                    Text(recording.formattedDuration)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    if isPlaying {
                        HStack(spacing: 4) {
                            Text(formatPlaybackTime(playbackTime))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.0))
                            Text("•")
                                .foregroundColor(.gray.opacity(0.5))
                            Text("Playing")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: onPlay) {
                        ZStack {
                            Circle()
                                .fill(isPlaying ? Color(red: 1.0, green: 0.8, blue: 0.0) : Color.gray.opacity(0.15))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 18))
                                .foregroundColor(isPlaying ? .black : .primary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: onDelete) {
                        ZStack {
                            Circle()
                                .fill(Color.red.opacity(0.1))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "trash.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.red)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            if isPlaying {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 4)
                            .cornerRadius(2)
                        
                        Rectangle()
                            .fill(Color(red: 1.0, green: 0.8, blue: 0.0))
                            .frame(width: geometry.size.width * CGFloat(playbackTime / recording.duration), height: 4)
                            .cornerRadius(2)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(20)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(16)
    }
    
    private func formatPlaybackTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Recording Screen with Waveform
struct RecordingScreen: View {
    @ObservedObject var audioManager: AudioRecorderManager
    @Binding var isPresented: Bool
    @State private var waveformSamples: [Float] = Array(repeating: 0.0, count: 50)
    
    var body: some View {
        ZStack {
            Color(red: 200/255, green: 213/255, blue: 208/255)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Recording")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 40)
                
                Spacer()
                
                // Time Display
                Text(formatTime(audioManager.recordingTime))
                    .font(.system(size: 72, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.0))
                    .padding(.bottom, 50)
                
                // Waveform Visualization
                VStack(spacing: 16) {
                    Text("Recording in progress...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                    
                    WaveformView(samples: waveformSamples)
                        .frame(height: 150)
                        .padding(.horizontal, 24)
                }
                .padding(.vertical, 30)
                .background(Color.white.opacity(0.5))
                .cornerRadius(24)
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Stop Button
                Button(action: {
                    audioManager.stopRecording()
                    isPresented = false
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Stop")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            Text("Recording")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "stop.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(20)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
                .buttonStyle(PlainButtonStyle())
            }
        }
        .onChange(of: audioManager.audioLevel) { _, newValue in
            // Update waveform samples with new audio level
            waveformSamples.removeFirst()
            waveformSamples.append(newValue)
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%01d", minutes, seconds, milliseconds)
    }
}

// MARK: - Waveform Visualization
struct WaveformView: View {
    let samples: [Float]
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 3) {
                ForEach(samples.indices, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(red: 1.0, green: 0.8, blue: 0.0))
                        .frame(
                            width: max(2, (geometry.size.width - CGFloat(samples.count - 1) * 3) / CGFloat(samples.count)),
                            height: max(4, CGFloat(samples[index]) * geometry.size.height)
                        )
                        .animation(.easeOut(duration: 0.1), value: samples[index])
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

#Preview {
    ContentView()
}

