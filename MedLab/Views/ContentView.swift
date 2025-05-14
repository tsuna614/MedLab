//
//  ContentView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 25/3/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()
    @StateObject var snackbarViewModel = SnackBarViewModel() // Assuming global snackbar needed
    
    // --- Dependencies (Create instances once) ---
    @StateObject private var apiClient: ApiClient
    @StateObject private var cartService: CartService
    @StateObject private var orderService: OrderService // Added OrderService
    
    // --- ViewModels (Depend on Services) ---
    @StateObject private var cartViewModel: CartViewModel
    @StateObject private var orderViewModel: OrderViewModel // Added OrderViewModel
    
    // Localization Settings
    @StateObject private var languageSettings = LanguageSettingsObserver()

    
    init() {
        // Api client
        let apiClientInstance = ApiClient(baseURLString: "http://localhost:3000")
        
        // Services
        let cartServiceInstance = CartService(apiClient: apiClientInstance)
        let orderServiceInstance = OrderService(apiClient: apiClientInstance)

        // Initialize the @StateObject wrappers for services
        _cartService = StateObject(wrappedValue: cartServiceInstance)
        _orderService = StateObject(wrappedValue: orderServiceInstance)
        _apiClient = StateObject(wrappedValue: apiClientInstance)
        
        // Create VM instance
        let appVMInstance = AppViewModel()
        let cartVMInstance = CartViewModel(cartService: cartServiceInstance)
        
        // View Models
        _appViewModel = StateObject(wrappedValue: appVMInstance) // Initialize its wrapper
        _cartViewModel = StateObject(wrappedValue: cartVMInstance)
        _orderViewModel = StateObject(wrappedValue: OrderViewModel(
            orderService: orderServiceInstance,
            cartViewModel: cartVMInstance,
            appViewModel: appVMInstance
        ))
    }
    
    var body: some View {
        
        if languageSettings.currentLocaleIdentifier == "default" {
            ZStack {
                Group {
                    if appViewModel.isLoading {
                        ProgressView("Checking login...")
                    } else if appViewModel.isAuthenticated {
                        MainTabView()
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
            .environmentObject(cartViewModel)
            .environmentObject(orderViewModel)
            .environmentObject(snackbarViewModel)
            .environmentObject(languageSettings)
        } else {
            ZStack {
                Group {
                    if appViewModel.isLoading {
                        ProgressView("Checking login...")
                    } else if appViewModel.isAuthenticated {
                        MainTabView()
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
            .environmentObject(cartViewModel)
            .environmentObject(orderViewModel)
            .environmentObject(snackbarViewModel)
            .environment(\.locale, Locale(identifier: languageSettings.currentLocaleIdentifier))
            .environmentObject(languageSettings)
        }
    }
}

#Preview {
    ContentView()
}
