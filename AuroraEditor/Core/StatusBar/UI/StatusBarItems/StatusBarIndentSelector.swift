//
//  StatusBarIndentSelector.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 22.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A selector for the indent of the status bar.
internal struct StatusBarIndentSelector: View {

    /// The preferences of the app.
    @StateObject
    private var prefs: AppPreferencesModel = .shared

    /// The view body.
    internal var body: some View {
        Menu {
            Button {} label: {
                Text("Use Tabs")
            }.disabled(true)

            Button {} label: {
                Text("Use Spaces")
            }.disabled(true)

            Divider()

            Picker("Tab Width", selection: $prefs.preferences.textEditing.defaultTabWidth) {
                ForEach(2..<9) { index in
                    Text("\(index) Spaces")
                        .tag(index)
                }
            }
        } label: {
            StatusBarMenuLabel("\(prefs.preferences.textEditing.defaultTabWidth) Spaces")
        }
        .menuIndicator(.hidden)
        .menuStyle(.borderlessButton)
        .fixedSize()
        .onHover { isHovering($0) }
    }
}
