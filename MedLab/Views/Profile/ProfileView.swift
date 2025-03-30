//
//  ProfileView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 30/3/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            if let user = appViewModel.user {
                Text("Welcome \(user.firstName.capitalized) \(user.lastName.capitalized)")
            }
            
            Button("Print user") {
                print(appViewModel.user!)
            }
            
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

#Preview {
    ProfileView()
}
