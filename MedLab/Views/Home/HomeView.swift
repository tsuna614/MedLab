//
//  HomeView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 26/3/25.
//

import SwiftUI

struct HomeView: View {
    
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TopBar()

                
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Want to get medical advice or book an appointment?")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.top, .leading, .trailing])
                        
                        CallToActionCard(
                            title: "Find a Doctor",
                            subtitle: "Search for specialists and book appointments easily.",
                            imageName: "figure.run.square.stack.fill",
                            backgroundColor: .blue,
                            destinationView: DoctorListView()
                        )
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        CategoryView()
                            .padding(.bottom, 20)
                        
                        HomeBottomDecorativeView()
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Home")
            .navigationBarHidden(true)
        }
    }
}


struct CallToActionCard<Destination: View>: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let imageName: String // SF Symbol name or asset name
    let backgroundColor: Color
    let destinationView: Destination

    var body: some View {
        NavigationLink(destination: destinationView) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.title2.weight(.bold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.callout)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: imageName)
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(20) // Generous padding inside the card
            .frame(maxWidth: .infinity) // Take full available width
            .background(backgroundColor)
            .cornerRadius(15)
            .shadow(color: backgroundColor.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle()) // Ensure the whole card is tappable
    }
}
