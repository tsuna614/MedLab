//
//  ClassifyView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 30/3/25.
//

import SwiftUI

struct OrderView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TopBar(title: "Order")
                
                Spacer()
                
                Text("Order View")
                Button("Print Cart") {
                    cartViewModel.printItems()
                }
                
                Spacer()
            }
            .navigationTitle("Order")
            .navigationBarHidden(true)
        }
    }
}
