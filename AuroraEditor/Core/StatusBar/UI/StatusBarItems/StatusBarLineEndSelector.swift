//
//  StatusBarLineEndSelector.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 22.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A selector for the line end of the status bar.
internal struct StatusBarLineEndSelector: View {

    /// The view body.
    internal var body: some View {
        Menu {
            // LF, CRLF
        } label: {
            StatusBarMenuLabel("LF")
        }
        .menuIndicator(.hidden)
        .menuStyle(.borderlessButton)
        .fixedSize()
        .onHover { isHovering($0) }
    }
}
