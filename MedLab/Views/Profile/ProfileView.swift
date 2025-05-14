//
//  ProfileView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 30/3/25.
//

import SwiftUI

enum ProfileButtonTitle {
    case medicalRecord
    
    
}

struct ProfileView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var languageSettings: LanguageSettingsObserver // has to call this because settings will be needing it
    
    @State private var showingSignOutAlert: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    UserProfileCard(user: appViewModel.user)
                        .padding(.top)

                    VStack(spacing: 0) {
                        ProfileActionButton(title: "Medical Record", iconName: "heart.text.square.fill")
                        Divider().padding(.horizontal)

                        ProfileActionButton(title: "Rewards", iconName: "gift.fill")
                        Divider().padding(.horizontal)

                        ProfileActionButton(title: "Discount", iconName: "tag.fill")
                    }
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)


                    VStack(spacing: 0) {
                        ProfileActionButton(title: "Help Center", iconName: "questionmark.circle.fill")
                        Divider().padding(.horizontal)

                        ProfileActionButton(title: "Contact Us", iconName: "phone.fill")
                    }
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)


                    VStack(spacing: 0) {
                        NavigationLink {
                            SettingsView(initialLanguage: AppLanguage.from(localeIdentifier: languageSettings.currentLocaleIdentifier) ?? .english)
                        } label: {
                            ProfileActionButton(title: "Settings", iconName: "gearshape.fill")
                        }
                        
                         Divider().padding(.horizontal)

                        Button {
                            showingSignOutAlert = true
                        } label: {
                            ProfileActionButton(title: "Sign Out", iconName: "rectangle.portrait.and.arrow.right.fill", isDestructive: true)
                        }
                    }
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    Spacer()
                }
                .padding(.bottom)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profile")
            .alert("Confirmation", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) {
                    showingSignOutAlert = false
                }
                Button("Sign Out", role: .destructive) {
                    appViewModel.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

struct ProfileActionButton: View {
    let title: LocalizedStringKey
    let iconName: String
    var isDestructive: Bool = false

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(isDestructive ? .red : .accentColor)
                .frame(width: 25, alignment: .center)
            Text(title)
                .foregroundColor(isDestructive ? .red : .primary)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray.opacity(0.7))
        }
        .padding() // Padding inside the button content
        .contentShape(Rectangle())
    }
}
