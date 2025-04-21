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
            .environmentObject(appViewModel)
            
            if snackbarViewModel.showSnackbar {
                VStack {
                    Spacer()
                    SnackbarView(message: snackbarViewModel.message)
                }
                .padding(.bottom, 50)
            }
        }
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
