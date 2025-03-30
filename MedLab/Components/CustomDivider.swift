//
//  CustomDivider.swift
//  Moonshot
//
//  Created by Khanh Nguyen Quoc on 20/3/25.
//

import SwiftUI

struct CustomDivider: View {
    var body: some View {
        Rectangle()
            .frame(height: 2)
            .foregroundStyle(.lightBackground)
            .padding()
    }
}

#Preview {
    CustomDivider()
}
