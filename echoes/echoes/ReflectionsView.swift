//
//  ReflectionsView.swift
//  echoes
//
//  Created by Hubert Guzera on 26/12/2025.
//

import SwiftUI

struct ReflectionsView: View {
    @State private var selectedReflectionType: ReflectionType = .weekly
    @State private var selectedTopic = "Personal Growth"
    @State private var showChatInterface = false
    @State private var messageText = ""
    @State private var chatMessages: [ChatMessage] = [
        ChatMessage(text: "How did this week make you feel?", isFromUser: false),
        ChatMessage(text: "It was challenging but rewarding. I learned a lot about myself.", isFromUser: true),
        ChatMessage(text: "What was the most significant moment?", isFromUser: false)
    ]
    
    let reflectionTopics = ["Personal Growth", "Relationships", "Career", "Health", "Creativity", "Spirituality"]
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Weekly")
                            .font(.system(size: 48, weight: .black))
                            .foregroundColor(.appTextPrimary)
                        Text("Reflections")
                            .font(.system(size: 36, weight: .black))
                            .foregroundColor(.appTextPlaceholder)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showChatInterface = true
                    }) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.appTextPrimary)
                            .padding(12)
                            .background(Color.white.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 30)
                
                // Reflection Type Selector
                Picker("Reflection Type", selection: $selectedReflectionType) {
                    ForEach(ReflectionType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Current Week Overview
                        if selectedReflectionType == .weekly {
                            WeeklyReflectionCard()
                        }
                        
                        // Topic Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Focus Topic")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.appTextPrimary)
                                .padding(.horizontal, 24)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(reflectionTopics, id: \.self) { topic in
                                        TopicChip(
                                            topic: topic,
                                            isSelected: selectedTopic == topic
                                        ) {
                                            selectedTopic = topic
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        
                        // Reflection Prompts
                        VStack(spacing: 16) {
                            ForEach(getReflectionPrompts(), id: \.id) { prompt in
                                ReflectionPromptCard(prompt: prompt)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Previous Reflections
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Previous Reflections")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.appTextPrimary)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 12) {
                                ForEach(getPreviousReflections(), id: \.id) { reflection in
                                    PreviousReflectionCard(reflection: reflection)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.bottom, 30)
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $showChatInterface) {
            ChatInterfaceView(
                messages: $chatMessages,
                messageText: $messageText,
                topic: selectedTopic
            )
        }
    }
    
    private func getReflectionPrompts() -> [ReflectionPrompt] {
        switch selectedReflectionType {
        case .weekly:
            return [
                ReflectionPrompt(id: 1, question: "What was your biggest accomplishment this week?", category: selectedTopic),
                ReflectionPrompt(id: 2, question: "What challenged you the most?", category: selectedTopic),
                ReflectionPrompt(id: 3, question: "How did you grow personally?", category: selectedTopic),
                ReflectionPrompt(id: 4, question: "What would you do differently?", category: selectedTopic)
            ]
        case .daily:
            return [
                ReflectionPrompt(id: 5, question: "How are you feeling right now?", category: selectedTopic),
                ReflectionPrompt(id: 6, question: "What brought you joy today?", category: selectedTopic),
                ReflectionPrompt(id: 7, question: "What did you learn today?", category: selectedTopic)
            ]
        case .monthly:
            return [
                ReflectionPrompt(id: 8, question: "What patterns do you notice this month?", category: selectedTopic),
                ReflectionPrompt(id: 9, question: "How have your priorities shifted?", category: selectedTopic),
                ReflectionPrompt(id: 10, question: "What are you grateful for this month?", category: selectedTopic)
            ]
        }
    }
    
    private func getPreviousReflections() -> [PreviousReflection] {
        return [
            PreviousReflection(
                id: 1,
                date: Date().addingTimeInterval(-7 * 86400),
                title: "Week of Growth",
                summary: "Focused on personal development and building new habits...",
                topic: "Personal Growth"
            ),
            PreviousReflection(
                id: 2,
                date: Date().addingTimeInterval(-14 * 86400),
                title: "Relationship Insights",
                summary: "Explored communication patterns and emotional connections...",
                topic: "Relationships"
            ),
            PreviousReflection(
                id: 3,
                date: Date().addingTimeInterval(-21 * 86400),
                title: "Career Reflection",
                summary: "Analyzed professional goals and upcoming opportunities...",
                topic: "Career"
            )
        ]
    }
}

enum ReflectionType: String, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
}

struct ReflectionPrompt: Identifiable {
    let id: Int
    let question: String
    let category: String
}

struct PreviousReflection: Identifiable {
    let id: Int
    let date: Date
    let title: String
    let summary: String
    let topic: String
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp = Date()
}

// MARK: - Supporting Views

struct WeeklyReflectionCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("December 23-29, 2025")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                    Text("This Week's Journey")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.appTextPrimary)
                }
                Spacer()
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 24))
                    .foregroundColor(.appPrimary)
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mood Trend")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                    HStack(spacing: 2) {
                        ForEach(0..<7) { day in
                            Circle()
                                .fill(day < 5 ? Color.appPrimary : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Progress")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                    Text("4/7 days")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appPrimary)
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.6))
        .cornerRadius(16)
        .padding(.horizontal, 24)
    }
}

struct TopicChip: View {
    let topic: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(topic)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .black : .appTextPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.appPrimary : Color.white.opacity(0.3))
                .cornerRadius(20)
        }
    }
}

struct ReflectionPromptCard: View {
    let prompt: ReflectionPrompt
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(prompt.question)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.appTextPrimary)
            
            TextEditor(text: .constant(""))
                .frame(height: 80)
                .padding(12)
                .background(Color.white.opacity(0.5))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
        .padding(16)
        .background(Color.white.opacity(0.3))
        .cornerRadius(12)
    }
}

struct PreviousReflectionCard: View {
    let reflection: PreviousReflection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(reflection.formattedDate)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.appTextSecondary)
                    Text(reflection.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                }
                Spacer()
                Text(reflection.topic)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.appPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.appPrimary.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Text(reflection.summary)
                .font(.system(size: 14))
                .foregroundColor(.appTextSecondary)
                .lineLimit(2)
        }
        .padding(16)
        .background(Color.white.opacity(0.4))
        .cornerRadius(12)
    }
}

struct ChatInterfaceView: View {
    @Binding var messages: [ChatMessage]
    @Binding var messageText: String
    @Environment(\.dismiss) var dismiss
    let topic: String
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Reflection Chat")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.appTextPrimary)
                    Spacer()
                    Text(topic)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.appPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.appPrimary.opacity(0.1))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.3))
                
                // Messages
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            ChatBubbleView(message: message)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
                
                // Input
                HStack(spacing: 12) {
                    TextField("Type your reflection...", text: $messageText, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(1...3)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.appPrimary)
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            .background(Color.appBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.appPrimary)
                }
            }
        }
    }
    
    private func sendMessage() {
        let userMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userMessage.isEmpty else { return }
        
        messages.append(ChatMessage(text: userMessage, isFromUser: true))
        messageText = ""
        
        // Simulate AI response after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let responses = [
                "That's an interesting perspective. Can you tell me more about that feeling?",
                "How do you think this connects to your overall goals?",
                "What emotions does this bring up for you?",
                "Have you experienced something similar before?",
                "What would you like to explore further about this?"
            ]
            
            if let randomResponse = responses.randomElement() {
                messages.append(ChatMessage(text: randomResponse, isFromUser: false))
            }
        }
    }
}

struct ChatBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                Text(message.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.appPrimary)
                    .foregroundColor(.black)
                    .cornerRadius(18, corners: [.topLeft, .topRight, .bottomLeft])
                    .frame(maxWidth: 280, alignment: .trailing)
            } else {
                Text(message.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.8))
                    .foregroundColor(.appTextPrimary)
                    .cornerRadius(18, corners: [.topLeft, .topRight, .bottomRight])
                    .frame(maxWidth: 280, alignment: .leading)
                Spacer()
            }
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ReflectionsView()
}