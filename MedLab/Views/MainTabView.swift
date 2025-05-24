//
//  MainTabView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 30/3/25.
//

import SwiftUI

struct MainTabView: View {
    // --- ViewModels ---
    @StateObject private var cartViewModel: CartViewModel
    @StateObject private var orderViewModel: OrderViewModel
    
    private let appViewModel: AppViewModel
    
    init(appViewModel: AppViewModel) {
        // Api client
        let apiClientInstance = ApiClient(baseURLString: "http://localhost:3000")
        
        // Services
        let cartServiceInstance = CartService(apiClient: apiClientInstance)
        let orderServiceInstance = OrderService(apiClient: apiClientInstance)

        // Create VM instance
//        let appVMInstance = AppViewModel()
        let cartVMInstance = CartViewModel(cartService: cartServiceInstance)
        
        // View Models
        _cartViewModel = StateObject(wrappedValue: cartVMInstance)
        _orderViewModel = StateObject(wrappedValue: OrderViewModel(
            orderService: orderServiceInstance,
            cartViewModel: cartVMInstance,
            appViewModel: appViewModel
        ))
        
        self.appViewModel = appViewModel
    }
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            ProductView()
                .tabItem {
                    Label("Product", systemImage: "square.grid.2x2.fill")
                }

            OrderView()
                .tabItem {
                    Label("Order", systemImage: "text.document.fill")
                }
            
//            MessageView()
            GuideView()
                .tabItem {
                    Label("Chat", systemImage: "text.bubble.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
        .environmentObject(cartViewModel)
        .environmentObject(orderViewModel)
    }
}
