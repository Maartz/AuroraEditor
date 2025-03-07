//
//  PreviewThemeView.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 31.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view that represents the preview of the selected theme.
struct PreviewThemeView: View {
    /// Theme model
    @StateObject
    private var themeModel: ThemeModel = .shared

    /// The view body
    var body: some View {
        ZStack(alignment: .topLeading) {
            EffectView(.contentBackground)
            if themeModel.selectedTheme == nil {
                Text("settings.theme.selection")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                Text("Preview is not yet implemented")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
    }
}

private struct PreviewThemeView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewThemeView()
    }
}
