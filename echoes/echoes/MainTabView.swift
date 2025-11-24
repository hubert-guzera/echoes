//
//  MainTabView.swift
//  echoes
//
//  Created by Hubert Guzera on 30/10/2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 1 // Start at ContentView (middle)
    
    var body: some View {
        TabView(selection: $selectedTab) {
            IssuesView()
                .tag(0)
            
            ContentView()
                .tag(1)
            
            MemoriesView()
                .tag(2)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .ignoresSafeArea()
    }
}

#Preview {
    MainTabView()
        .environmentObject(FirebaseAuthManager())
}
