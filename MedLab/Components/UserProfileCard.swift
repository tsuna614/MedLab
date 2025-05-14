//
//  UserProfileCard.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 1/4/25.
//

import SwiftUI

struct UserProfileCard: View {
    // The User object to display. Will come from AppViewModel.
    let user: User? // Make it optional in case user is not loaded yet

    var body: some View {
        VStack(spacing: 15) {
            // Avatar (Placeholder)
            Image(systemName: "person.crop.circle.fill") // Placeholder avatar
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
                .padding(.top)

            // User Name
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

                // You could add more info here like userType if desired
            } else {
                Text("Loading Profile...")
                    .font(.title2.weight(.semibold))
                    .redacted(reason: .placeholder) // Show placeholders while loading
                Text("email@example.com")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .redacted(reason: .placeholder)
            }

            // Edit Profile Button
            NavigationLink {
                // Destination: EditProfileView (create this view later)
                EditProfileView(user: user) // Pass the user object
            } label: {
                Text("Edit Profile")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .disabled(user == nil) // Disable if user data isn't loaded
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground)) // Or any other card background
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
        .padding(.horizontal) // Padding for the card itself
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
