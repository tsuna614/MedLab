//
//  UserProfileCard.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 1/4/25.
//

import SwiftUI

struct UserProfileCard: View {
    @EnvironmentObject var appViewModel: AppViewModel
    let user: User?
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
                .padding(.top)

            if let user = user {
                Text("\(user.firstName) \(user.lastName)")
                    .font(.title2.weight(.semibold))

                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if let number = user.number, !number.isEmpty {
                    Text("Phone: \(number)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

            } else {
                Text("Loading Profile...")
                    .font(.title2.weight(.semibold))
                    .redacted(reason: .placeholder)
                Text("email@example.com")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .redacted(reason: .placeholder)
            }

            NavigationLink {
                EditProfileView(viewModel: EditProfileViewModel(user: user, appViewModel: appViewModel))
            } label: {
                Text("Edit Profile")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .disabled(user == nil)
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
        .padding(.horizontal)
    }
}

//struct UserProfileCard: View {
//    let user: User?
//
//    var body: some View {
//        if let user = user {
//            VStack(spacing: 12) {
//                // Placeholder avatar
//                Image(systemName: "person.crop.circle.fill")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 80, height: 80)
//                    .foregroundColor(.gray)
//
//                // User name
//                Text("\(user.firstName.capitalized) \(user.lastName.capitalized)")
//                    .font(.title3)
//                    .fontWeight(.semibold)
//
//                // Email
//                Text(user.email)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(Color(.systemGray6))
//            .cornerRadius(12)
//            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
//        } else {
//            Text("User not found")
//                .foregroundColor(.gray)
//        }
//    }
//}
