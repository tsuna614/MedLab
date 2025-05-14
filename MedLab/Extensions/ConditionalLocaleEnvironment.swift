//
//  ConditionalLocaleEnvironment.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 13/5/25.
//

import SwiftUI

// this is to switch the local between user's choice and system default (injected in ContentView)

struct ConditionalLocaleEnvironment: ViewModifier {
    let localeIdentifier: String?

    func body(content: Content) -> some View {
        if let id = localeIdentifier {
            content.environment(\.locale, Locale(identifier: id))
        } else {
            content // Return content unmodified
        }
    }
}

extension View {
    func conditionalLocale(identifier: String?) -> some View {
        self.modifier(ConditionalLocaleEnvironment(localeIdentifier: identifier))
    }
}
