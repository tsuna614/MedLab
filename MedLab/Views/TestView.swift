//
//  TestView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 13/4/25.
//

import SwiftUI

struct TestView: View {
    @StateObject var viewModel = CounterViewModel()
    
    var body: some View {
        VStack {
            ForEach(viewModel.counters) { counter in
                TestView2(counter: counter)
            }
        }
        .environmentObject(viewModel)
    }
}

struct TestView2: View {
    let counter: Counter
    @EnvironmentObject var viewModel: CounterViewModel
    
    
    var body: some View {
        VStack {
            Text("Counter: \(counter.count)")
            
            Button("Increment") {
                viewModel.increment(counter: counter)
            }
            
            Button("Decrement") {
                viewModel.decrement(counter: counter)
            }
        }
    }
}

#Preview {
    TestView()
}
