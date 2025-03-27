//
//  ContentView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 25/3/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some View {
        Group {
            if appViewModel.isLoading {
                ProgressView("Checking login...")
            } else if appViewModel.isAuthenticated {
                HomeView()
            } else {
                LoginView()
            }
        }
        .environmentObject(appViewModel)
    }
}

#Preview {
    ContentView()
}
