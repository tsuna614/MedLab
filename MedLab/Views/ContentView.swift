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
    
//    // Initialize services
//    @StateObject var doctorService: DoctorService

    
    init() {
        // Api client
        let apiClientInstance = ApiClient(baseURLString: base_url)
        
        // Services
        let userServiceInstance = UserService(apiClient: apiClientInstance)
//        let doctorServiceInstance = DoctorService(apiClient: apiClientInstance)
//        _doctorService = StateObject(wrappedValue: doctorServiceInstance)
        
        // Create VM instance
        let appVMInstance = AppViewModel(userService: userServiceInstance)
        
        // View Models
        _appViewModel = StateObject(wrappedValue: appVMInstance)
    }
    
    var body: some View {
        
        let currentLocale: Locale = {
            if languageSettings.currentLocaleIdentifier == "default" || languageSettings.currentLocaleIdentifier.isEmpty {
                return Locale.current
            } else {
                return Locale(identifier: languageSettings.currentLocaleIdentifier)
            }
        }()
        
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
//        .environmentObject(doctorService)
        // .environment(\.locale, Locale(identifier: languageSettings.currentLocaleIdentifier))
        .environment(\.locale, currentLocale)
        
//        if languageSettings.currentLocaleIdentifier == "default" {
//            ZStack {
//                Group {
//                    if appViewModel.isLoading {
//                        ProgressView("Checking login...")
//                    } else if appViewModel.isAuthenticated {
//                        MainTabView(appViewModel: appViewModel)
//                    } else {
//                        LoginView()
//                    }
//                }
//                
//                if snackbarViewModel.showSnackbar {
//                    VStack {
//                        Spacer()
//                        SnackbarView(message: snackbarViewModel.message)
//                    }
//                    .padding(.bottom, 50)
//                }
//            }
//            .environmentObject(appViewModel)
//            .environmentObject(snackbarViewModel)
//            .environmentObject(languageSettings)
//            .environmentObject(doctorService)
//        } else {
//            ZStack {
//                Group {
//                    if appViewModel.isLoading {
//                        ProgressView("Checking login...")
//                    } else if appViewModel.isAuthenticated {
//                        MainTabView(appViewModel: appViewModel)
//                    } else {
//                        LoginView()
//                    }
//                }
//                
//                if snackbarViewModel.showSnackbar {
//                    VStack {
//                        Spacer()
//                        SnackbarView(message: snackbarViewModel.message)
//                    }
//                    .padding(.bottom, 50)
//                }
//            }
//            .environmentObject(appViewModel)
//            .environmentObject(snackbarViewModel)
//            .environmentObject(languageSettings)
//            .environmentObject(doctorService)
//            // .environment(\.locale, Locale(identifier: languageSettings.currentLocaleIdentifier))
//            .environment(\.locale, currentLocale)
//        }
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
