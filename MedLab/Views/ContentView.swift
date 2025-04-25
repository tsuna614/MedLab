//
//  ContentView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 25/3/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()
    @StateObject var snackbarViewModel = SnackBarViewModel()
    @StateObject private var apiClient = ApiClient(baseURLString: "http://localhost:3000") // Use your actual URL
    @StateObject private var cartService: CartService // Declare type
    @StateObject private var cartViewModel: CartViewModel
    
    init() {
        // Create the ApiClient first (or receive it)
        let apiClientInstance = ApiClient(baseURLString: "http://localhost:3000") // Or retrieve existing instance
        // Now create the services that DEPEND on the apiClient
        let cartServiceInstance = CartService(apiClient: apiClientInstance)
        // Now create the ViewModels that DEPEND on the services
        _cartService = StateObject(wrappedValue: cartServiceInstance) // Initialize StateObject correctly
        _cartViewModel = StateObject(wrappedValue: CartViewModel(cartService: cartServiceInstance)) // Inject service
        _apiClient = StateObject(wrappedValue: apiClientInstance) // Only if ContentView truly owns ApiClient lifecycle
        
        // Alternatively, if App struct owns ApiClient/Services:
        // You might pass cartService into ContentView's init instead of creating here.
    }
    
    var body: some View {
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
        .environmentObject(snackbarViewModel)
    }
}

//struct ContentView: View {
//    @StateObject var snackbarViewModel = SnackBarViewModel()
//
//    var body: some View {
//        ZStack {
//            VStack {
//                Button("Show Snackbar") {
//                    withAnimation {
//                        snackbarViewModel.showSnackbar(message: "Snack bar is pressed!")
//                    }
//                }
//            }
//
//            if snackbarViewModel.showSnackbar {
//                VStack {
//                    Spacer()
//                    SnackbarView(message: snackbarViewModel.message)
//                }
//                .padding(.bottom, 50)
//            }
//        }
//    }
//}

#Preview {
    ContentView()
}
