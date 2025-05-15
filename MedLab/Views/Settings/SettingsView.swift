//
//  SettingsView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 9/5/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var languageSettings: LanguageSettingsObserver
    @EnvironmentObject var snackbarViewModel: SnackBarViewModel
    
    @State private var isDarkModeEnabled: Bool = false

    @State private var selectedLanguage: AppLanguage = .systemDefault
    
    init(initialLanguage: AppLanguage) {
        _selectedLanguage = State(initialValue: initialLanguage)
    }

    var body: some View {
        Form {
            Section(header: Text("Appearance")) {
                Toggle("Dark Mode", isOn: $isDarkModeEnabled)
                    .onChange(of: isDarkModeEnabled) { oldValue, newValue in
                        print("Dark Mode toggled to: \(newValue)")
                    }

                Picker("Language", selection: $selectedLanguage) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.rawValue).tag(language)
                    }
                }
                .onChange(of: selectedLanguage) { oldValue, newValue in
                    print("Language changed to: \(newValue.rawValue)")
                    print("Old value: \(oldValue.rawValue)")
                    snackbarViewModel.showSnackbar(message: "Language changed to \(newValue.rawValue)")
                    languageSettings.updateLanguage(to: newValue)
                }
            }

            Section(header: Text("Account")) {
                NavigationLink {
                    EditProfileView(viewModel: EditProfileViewModel(user: appViewModel.user, appViewModel: appViewModel))
                } label: {
                    Button("Edit Profile") {}
                }
                Button("Change Password") {
                    print("Navigate to Change Password")
                }
            }

            Section(header: Text("About")) {
                HStack {
                    Text("App Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                Button("Privacy Policy") { print("Show Privacy Policy") }
                Button("Terms of Service") { print("Show Terms of Service") }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            let currentGlobalLanguage = AppLanguage.from(localeIdentifier: languageSettings.currentLocaleIdentifier) ?? .systemDefault
            print("Selected language: \(selectedLanguage.rawValue)")
            if selectedLanguage != currentGlobalLanguage {
                selectedLanguage = currentGlobalLanguage
                print("SettingsView.onAppear: Synced selectedLanguage with global setting: \(currentGlobalLanguage.rawValue)")
            }
        }
    }
    
    private func applyLanguageChange(_ language: AppLanguage) {
        print("Attempting to apply language: \(language.localeIdentifier)")
        
        UserDefaults.standard.set([language.localeIdentifier], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        print("Language preference saved. App may need to be re-rendered or restarted for full language change.")
    }
}
