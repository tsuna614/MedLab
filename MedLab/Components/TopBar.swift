//
//  TopBar.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 31/3/25.
//

import SwiftUI

struct TopBar: View {
    var title: String = ""
    @State private var searchText = ""
    @EnvironmentObject var cartViewModel: CartViewModel
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    print("Menu Tapped")
                }, label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                })
                
                if title.isEmpty {
                    Group {
                        Spacer()
                        
                        TextField("Search...", text: .constant(""))
                            .padding(8)
                            .padding(.horizontal, 4)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                } else {
                    Spacer()
                }
                
                NavigationLink(destination: CartView()) {
                    // Use a ZStack to overlay the badge on the icon
                    ZStack(alignment: .topTrailing) { // Align content to top-right
                        // Base Cart Icon
                        Image(systemName: "cart")
                            .font(.title2)
                        
                        // 3. Conditional Badge View
                        if cartViewModel.totalQuantity > 0 { // Only show if items exist
                            Text("\(cartViewModel.totalQuantity)")
                                .font(.caption2) // Make font small
                                .foregroundColor(.white)
                                .padding(4) // Padding inside the circle
                                .background(Color.red) // Badge background color
                                .clipShape(Circle()) // Make it circular
                            // Offset to position it correctly relative to the icon
                                .offset(x: 10, y: -10) // Adjust x/y as needed for visuals
                        }
                    }
                }
//                .foregroundColor(.primary)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 8)
            
            if !title.isEmpty {
                HStack {
                    
                    Text(title)
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
        }
    }
}
