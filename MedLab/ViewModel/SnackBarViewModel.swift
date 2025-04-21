//
//  SnackBarViewModel.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 18/4/25.
//

import SwiftUI

@MainActor
class SnackBarViewModel: ObservableObject {
    @Published private(set) var showSnackbar: Bool = false
    @Published private(set) var message: String = ""
    private var hideTask: Task<Void, Never>?
    
    func showSnackbar(message: String) {
        hideTask?.cancel()
        
        self.message = message
        self.showSnackbar = true
        
        // Auto-hide after 2 seconds
        hideTask = Task {
            // Use Task.sleep for modern async/await and cancellation
            guard (try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)) != nil else {
                // Task was cancelled (e.g., another showSnackbar was called)
                return
            }
            
            // --- Hide the Snackbar with Animation ---
            // Apply animation specifically when setting showSnackbar back to false
            withAnimation {
                self.showSnackbar = false
            }
        }
    }
    
    // dismiss function for when tapping on the snackbar
    func dismiss() {
        hideTask?.cancel()
        // Ensure manual dismissal is also animated
        withAnimation {
            self.showSnackbar = false
        }
    }
}
