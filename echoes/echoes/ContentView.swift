//
//  ContentView.swift
//  kotalojz
//
//  Created by Hubert Guzera on 30/10/2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var audioManager: AudioRecorderManager
    @EnvironmentObject var authManager: FirebaseAuthManager
    @State private var showRecordingScreen = false
    @State private var hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Bold Hero Title Section
                VStack(alignment: .leading, spacing: 4) {
                    Text("Echoes")
                        .font(.system(size: 48, weight: .black))
                        .foregroundColor(.appTextPrimary)
                    Text("Capturing ")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(.appTextPlaceholder)
                    Text("Memories")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(.appTextPlaceholder)
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 30)
                
                // Main Action Card
                Button(action: {
                    if !audioManager.isRecording {
                        hapticFeedback.impactOccurred()
                        audioManager.startRecording()
                        showRecordingScreen = true
                    }
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("New")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.appTextPrimary)
                            Text("Recording")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.appTextPrimary)
                        }
                        
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(Color.appPrimary)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "mic.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color.appPrimary)
                    .cornerRadius(20)
                }
                .padding(.horizontal, 24)
                .buttonStyle(PlainButtonStyle())
                .fullScreenCover(isPresented: $showRecordingScreen) {
                    RecordingScreen(audioManager: audioManager, isPresented: $showRecordingScreen)
                }
                
                // Quick Recording Status
                if audioManager.recordings.count > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(audioManager.recordings.count) memories captured")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.appTextSecondary)
                        
                        Text("Tap Memories to explore")
                            .font(.system(size: 14))
                            .foregroundColor(.appTextPlaceholder)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                }
                
                Spacer()
            }
        }
    }
}







// MARK: - Recording Screen with Waveform
struct RecordingScreen: View {
    @ObservedObject var audioManager: AudioRecorderManager
    @Binding var isPresented: Bool
    @State private var waveformSamples: [Float] = Array(repeating: 0.0, count: 50)
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Recording")
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(.appTextPrimary)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 40)
                
                Spacer()
                
                // Time Display
                Text(formatTime(audioManager.recordingTime))
                    .font(.system(size: 72, weight: .bold, design: .monospaced))
                    .foregroundColor(.appPrimary)
                    .padding(.bottom, 50)
                
                // Waveform Visualization
                VStack(spacing: 16) {
                    Text("Recording in progress...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                    
                    WaveformView(samples: waveformSamples)
                        .frame(height: 150)
                        .padding(.horizontal, 24)
                }
                .padding(.vertical, 30)
                .background(Color.appCardBackground)
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
                    .background(Color.appError)
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
                        .fill(Color.appPrimary)
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
    ContentView(audioManager: AudioRecorderManager())
        .environmentObject(FirebaseAuthManager())
}

