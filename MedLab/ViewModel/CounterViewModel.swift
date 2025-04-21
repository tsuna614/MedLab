//
//  CounterViewModel.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 21/4/25.
//

import SwiftUI

@MainActor
class CounterViewModel: ObservableObject {
    @Published var counters: [Counter]
    
    // MARK: - init
    init() {
        self.counters = [Counter(count: 0), Counter(count: 0)]
    }
    
    func increment(counter: Counter) {
        if let index = counters.firstIndex(where: {$0.id == counter.id}) {
            counters[index].count += 1
            print("increment")
        }
    }
    
    func decrement(counter: Counter) {
        if let index = counters.firstIndex(where: {$0.id == counter.id}) {
            counters[index].count -= 1
            print("decrement")
        }
    }
}
