//
//  MemoriesView.swift
//  echoes
//
//  Created by Hubert Guzera on 30/10/2025.
//

import SwiftUI

struct MemoriesView: View {
    @State private var selectedDate = Date()
    
    // Placeholder data
    let memories = [
        Memory(date: Date(), title: "Coffee with Sarah", summary: "Discussed the new project ideas."),
        Memory(date: Date().addingTimeInterval(-86400), title: "Team Meeting", summary: "Weekly sync with the engineering team."),
        Memory(date: Date().addingTimeInterval(-86400 * 2), title: "Grocery Shopping", summary: "Bought ingredients for dinner.")
    ]
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Memories")
                        .font(.system(size: 48, weight: .black))
                        .foregroundColor(.appTextPrimary)
                    Text("Calendar")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(.appTextPlaceholder)
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 30)
                
                // Calendar
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                .accentColor(.appPrimary)
                
                // Memories List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(memories) { memory in
                            MemoryCard(memory: memory)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
            }
        }
    }
}

struct Memory: Identifiable {
    let id = UUID()
    let date: Date
    let title: String
    let summary: String
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct MemoryCard: View {
    let memory: Memory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(memory.formattedDate)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appTextSecondary)
            
            Text(memory.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.appTextPrimary)
            
            Text(memory.summary)
                .font(.system(size: 14))
                .foregroundColor(.appTextSecondary)
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.6))
        .cornerRadius(12)
    }
}

#Preview {
    MemoriesView()
}
