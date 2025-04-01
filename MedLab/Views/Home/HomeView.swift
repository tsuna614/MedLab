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
                    CategoryView()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}


struct CategoryView: View {
    let columns = [GridItem(.flexible()), GridItem(.flexible())] // 2-column layout

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(ProductCategory.allCases) { category in
                        CategoryCard(category: category)
                    }
                }
                .padding()
            }
            .navigationTitle("Categories")
        }
    }
}

//struct CategoryCard: View {
//    let category: ProductCategory
//    
//    var body: some View {
//        NavigationLink(destination: ProductListView(category: category)) {
//            VStack {
//                Text(category.title)
//                    .font(.headline)
//            }
//            .frame(maxWidth: .infinity)
//            .padding()
//            .background(Color(.systemGray6))
//            .cornerRadius(12)
//            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
//        }
//    }
//}

struct CategoryCard: View {
    let category: ProductCategory

    var body: some View {
        NavigationLink(destination: ProductListView(category: category)) {
            ZStack(alignment: .bottomTrailing) {
                // Background image
                Image(category.imagePath)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .opacity(0.75) // faded image effect
//                    .padding()

                // Title text
                VStack(alignment: .leading) {
                    Text(category.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding([.top, .leading, .trailing])
                    
                    Text(category.description)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .padding(.horizontal)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 140) // your fixed card size
//            .background(Color(.systemGray6))
            .background(category.color.opacity(0.2))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle()) // optional: removes NavigationLink highlight
    }
}
