//
//  HomeView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 26/3/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TopBar()

                ScrollView {
                    CategoryView()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

