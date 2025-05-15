//
//  ContentView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 25/3/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel: AppViewModel
    @StateObject var snackbarViewModel = SnackBarViewModel()
    
    // Localization Settings
    @StateObject private var languageSettings = LanguageSettingsObserver()

    
    init() {
        // Api client
        let apiClientInstance = ApiClient(baseURLString: "http://localhost:3000")
        
        // Services
        let userServiceInstance = UserService(apiClient: apiClientInstance)
        
        // Create VM instance
        let appVMInstance = AppViewModel(userService: userServiceInstance)
        
        // View Models
        _appViewModel = StateObject(wrappedValue: appVMInstance)
    }
    
    var body: some View {
        
        if languageSettings.currentLocaleIdentifier == "default" {
            ZStack {
                Group {
                    if appViewModel.isLoading {
                        ProgressView("Checking login...")
                    } else if appViewModel.isAuthenticated {
                        MainTabView(appViewModel: appViewModel)
                    } else {
                        LoginView()
                    }
                }
                
                if snackbarViewModel.showSnackbar {
                    VStack {
                        Spacer()
                        SnackbarView(message: snackbarViewModel.message)
                    }
                    .padding(.bottom, 50)
                }
            }
            .environmentObject(appViewModel)
            .environmentObject(snackbarViewModel)
            .environmentObject(languageSettings)
        } else {
            ZStack {
                Group {
                    if appViewModel.isLoading {
                        ProgressView("Checking login...")
                    } else if appViewModel.isAuthenticated {
                        MainTabView(appViewModel: appViewModel)
                    } else {
                        LoginView()
                    }
                }
                
                if snackbarViewModel.showSnackbar {
                    VStack {
                        Spacer()
                        SnackbarView(message: snackbarViewModel.message)
                    }
                    .padding(.bottom, 50)
                }
            }
            .environmentObject(appViewModel)
            .environmentObject(snackbarViewModel)
            .environment(\.locale, Locale(identifier: languageSettings.currentLocaleIdentifier))
            .environmentObject(languageSettings)
        }
    }
}

#Preview {
    ContentView()
}

//#Preview {
//    let appPreviewVM = AppViewModel()
//    // You can set this to true to specifically test the MainTabView branch in preview
//    // appPreviewVM.isAuthenticated = true
//    // appPreviewVM.isLoading = false
//
//    return ContentView()
//        .environmentObject(appPreviewVM)
//        .environmentObject(SnackBarViewModel())
//        .environmentObject(LanguageSettingsObserver())
//}
