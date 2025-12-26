//
//  MainTabView.swift
//  echoes
//
//  Created by Hubert Guzera on 30/10/2025.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var audioManager = AudioRecorderManager()
    
    var body: some View {
        TabView {
            IssuesView()
                .tabItem {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("Issues")
                }
            
            ContentView(audioManager: audioManager)
                .tabItem {
                    Image(systemName: "mic.circle.fill")
                    Text("Recording")
                }
            
            MemoriesView(audioManager: audioManager)
                .tabItem {
                    Image(systemName: "waveform.circle.fill")
                    Text("Memories")
                }
            
            ReflectionsView()
                .tabItem {
                    Image(systemName: "lightbulb.circle.fill")
                    Text("Reflections")
                }
            
            OptionsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Options")
                }
        }
        .accentColor(Color(red: 1.0, green: 0.8, blue: 0.0))
    }
}

#Preview {
    MainTabView()
        .environmentObject(FirebaseAuthManager())
}
