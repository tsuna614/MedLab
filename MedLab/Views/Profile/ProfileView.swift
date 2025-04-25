//
//  ProfileView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 30/3/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TopBar(title: "Profile")
                
                UserProfileCard(user: appViewModel.user)

                Spacer()
                
                
                Button("Sign Out") {
                    cartViewModel.clearLocalCartData()
                    appViewModel.signOut()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Spacer()
            }
            .navigationTitle("Profile")
            .navigationBarHidden(true)
        }
    }
}
