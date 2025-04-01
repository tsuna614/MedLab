//
//  ClassifyView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 30/3/25.
//

import SwiftUI

struct OrderView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TopBar(title: "Order")
                
                Spacer()
                
                Text("Order View")
                
                Spacer()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}
