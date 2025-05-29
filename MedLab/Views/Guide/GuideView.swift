//
//  GuideView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 22/5/25.
//

import SwiftUI

struct GuideView: View {
    
    var body: some View {
        NavigationStack {
            VStack {
                TopBar(title: "Guide")
                
                List {
                    Section(header: Text("AI Powered Tools").font(.headline)) {
                        NavigationLink {
                            MedicineClassifierView()
                        } label: {
                            GuideLinkRow(
                                title: "Medicine Identifier",
                                description: "Take or select a photo of a medicine box to identify it.",
                                iconName: "camera.viewfinder",
                                iconColor: .blue
                            )
                        }
                        
                        NavigationLink {
                            MessageView()
                        } label: {
                            GuideLinkRow(
                                title: "AI Doctor Consultation",
                                description: "Ask general health questions or get information. Not for diagnosis.",
                                iconName: "message.badge.circle.fill",
                                iconColor: .green
                            )
                        }
                    }
                    
                }
                .listStyle(.insetGrouped)
            }
        }
    }
}

struct GuideLinkRow: View {
    let title: String
    let description: String
    let iconName: String
    let iconColor: Color

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 30, alignment: .center)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}


// MARK: - Placeholder Destination Views (for compilation)

struct MedicineClassifierView_GuidePreview: View { // Renamed for preview
    var body: some View {
        Text("Medicine Classifier Screen")
            .navigationTitle("Medicine Identifier")
    }
}

struct MessageView_GuidePreview: View { // Renamed for preview
    var body: some View {
        Text("AI Chatbot / Message Screen")
            .navigationTitle("AI Consultation")
    }
}
