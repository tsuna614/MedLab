//
//  MainTabView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 30/3/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            ProductView()
                .tabItem {
                    Label("Product", systemImage: "square.grid.2x2.fill")
                }

            OrderView()
                .tabItem {
                    Label("Order", systemImage: "text.document.fill")
                }
            
            MessageView()
                .tabItem {
                    Label("Chat", systemImage: "text.bubble.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}


#Preview {
    MainTabView()
}
