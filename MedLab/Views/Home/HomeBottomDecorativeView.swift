//
//  HomeBottomDecorativeView.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 16/6/25.
//

import SwiftUI

struct TitleObject: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
}

struct HomeBottomDecorativeView: View {
    let titlesAndIcons: [TitleObject] = [
        TitleObject(title: "Quick connection to pharmacists", icon: "phone.bubble.left.fill"),
        TitleObject(title: "Money-back guarantee if not satisfied", icon: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90"),
        TitleObject(title: "30-minute delivery anytime, day or night", icon: "clock.badge.checkmark.fill"),
        TitleObject(title: "100% authentic products", icon: "checkmark.seal.fill")
    ]
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            (
                Text("Why ") +
                Text("MedLab")
                    .foregroundColor(.blue)
                    .fontWeight(.bold) +
                Text(" is the best choice for purchasing medicine online")
            )
            .font(.title2.weight(.semibold))
            .padding([.top, .leading, .trailing])

            
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(titlesAndIcons) { item in
                    DecorativeItemView(item: item)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.systemGray6).opacity(0.7))
    }
}

struct DecorativeItemView: View {
    let item: TitleObject

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: item.icon)
                .font(.title)
                .foregroundColor(.accentColor)
                .frame(height: 40)

            Text(item.title)
                .font(.subheadline.weight(.medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .frame(minHeight: 50, alignment: .top)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}
