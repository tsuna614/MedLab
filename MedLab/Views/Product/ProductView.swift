//
//  SearchView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 30/3/25.
//

import SwiftUI

struct ProductView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TopBar(title: "Product")
                
                Spacer()
                
                Text("Product View")
                
                Spacer()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}
