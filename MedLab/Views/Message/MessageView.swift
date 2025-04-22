//
//  MessageView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 30/3/25.
//

import SwiftUI

struct MessageView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TopBar(title: "Message")
                
                Spacer()
                
                Text("Message View")
                
                Spacer()
            }
            .navigationTitle("Message")
            .navigationBarHidden(true)
        }
    }
}
