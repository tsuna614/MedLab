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
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "cart")
                            .font(.title2)
                        
                        if cartViewModel.totalQuantity > 0 {
                            Text("\(cartViewModel.totalQuantity)")
                                .font(.caption2)
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.red)
                                .clipShape(Circle())
                                .offset(x: 10, y: -10)
                        }
                    }
                }
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
