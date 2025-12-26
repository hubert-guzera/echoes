//
//  IssuesView.swift
//  echoes
//
//  Created by Hubert Guzera on 30/10/2025.
//

import SwiftUI

struct IssuesView: View {
    // Placeholder data
    let issues = [
        Issue(title: "Conversation with Kate", date: Date()),
        Issue(title: "Vacation Planning", date: Date().addingTimeInterval(-86400)),
        Issue(title: "Work-Life Balance", date: Date().addingTimeInterval(-86400 * 3)),
        Issue(title: "Family Dynamics", date: Date().addingTimeInterval(-86400 * 5))
    ]
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Topics")
                        .font(.system(size: 48, weight: .black))
                        .foregroundColor(.appTextPrimary)
                    Text("& Stories")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(.appTextPlaceholder)
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 30)
                
                // Issues List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(issues) { issue in
                            IssueCard(issue: issue)
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
            }
        }
    }
}

struct Issue: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct IssueCard: View {
    let issue: Issue
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(issue.formattedDate)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appTextSecondary)
                
                Text(issue.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.appTextPrimary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.appTextSecondary)
        }
        .padding(20)
        .background(Color.white.opacity(0.6))
        .cornerRadius(16)
    }
}

#Preview {
    IssuesView()
}
