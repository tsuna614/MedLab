//
//  UserProfileCard.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 1/4/25.
//

import SwiftUI

struct UserProfileCard: View {
    let user: User?

    var body: some View {
        if let user = user {
            VStack(spacing: 12) {
                // Placeholder avatar
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)

                // User name
                Text("\(user.firstName.capitalized) \(user.lastName.capitalized)")
                    .font(.title3)
                    .fontWeight(.semibold)

                // Email
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        } else {
            Text("User not found")
                .foregroundColor(.gray)
        }
    }
}
