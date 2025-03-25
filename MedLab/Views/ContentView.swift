//
//  ContentView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 25/3/25.
//

import SwiftUI

class CounterViewModel: ObservableObject {
    @Published var count = 0
    
    func increment() {
        
        count += 1
        print(count)
    }
}

struct ContentView: View {
    @StateObject var viewModel = CounterViewModel()
    
    var body: some View {
        VStack {
            Text("Counter: \(viewModel.count)")
            
            Button("Increment") {
                viewModel.increment()
            }
        }
    }
}

#Preview {
    ContentView()
}
