//
//  HomeView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 26/3/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("🏠 Home")
            
            Button("Sign Out") {
                appViewModel.signOut()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
}
