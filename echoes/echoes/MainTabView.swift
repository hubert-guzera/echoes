//
//  MainTabView.swift
//  echoes
//
//  Created by Hubert Guzera on 30/10/2025.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var audioManager = AudioRecorderManager()
    @EnvironmentObject var authManager: FirebaseAuthManager
    @State private var hapticFeedback = UISelectionFeedbackGenerator()
    
    var body: some View {
        TabView {
            // 1. Topics (formerly Issues)
            IssuesView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("Topics")
                }
            
            // 2. Memories
            MemoriesView(audioManager: audioManager)
                .tabItem {
                    Image(systemName: "waveform.circle.fill")
                    Text("Memories")
                }
            
            // 3. Recording
            ContentView(audioManager: audioManager)
                .tabItem {
                    Image(systemName: "mic.circle.fill")
                    Text("Recording")
                }
            
            // 4. Reflections
            ReflectionsView()
                .tabItem {
                    Image(systemName: "lightbulb.circle.fill")
                    Text("Reflections")
                }
            
            // 5. Options
            OptionsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Options")
                }
        }
        .accentColor(Color.appPrimary)
        .onChange(of: audioManager) { _, _ in
            hapticFeedback.selectionChanged()
        }
        .onAppear {
            hapticFeedback.prepare()
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(FirebaseAuthManager())
}
