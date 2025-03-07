//
//  TabBarItemButtonStyle.swift
//  Aurora Editor
//
//  Created by Khan Winter on 6/4/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// Tab bar item button style.
struct TabBarItemButtonStyle: ButtonStyle {

    /// Color scheme
    @Environment(\.colorScheme)
    var colorScheme

    /// Application preferences model
    @StateObject
    private var prefs: AppPreferencesModel = .shared

    /// Modifies the button.
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed
                ? (colorScheme == .dark ? .white.opacity(0.08) : .black.opacity(0.09))
                : .clear
            )
    }
}
