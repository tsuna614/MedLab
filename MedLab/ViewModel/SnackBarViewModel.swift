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
        
        hideTask = Task {
            guard (try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)) != nil else {
                return
            }
            
            withAnimation {
                self.showSnackbar = false
            }
        }
    }
    
    func dismiss() {
        hideTask?.cancel()
        withAnimation {
            self.showSnackbar = false
        }
    }
}
