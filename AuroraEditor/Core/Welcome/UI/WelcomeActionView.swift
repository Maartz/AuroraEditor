//
//  WelcomeActionView.swift
//  Aurora Editor
//
//  Created by Ziyuan Zhao on 2022/3/18.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

// A view to create a WelcomeActionView without having to
// write boilerplate code every time a new action needs to
// be added to the WelcomeView
public struct WelcomeActionView: View {
    /// Icon name
    var iconName: String

    /// Title
    var title: String

    /// Subtitle
    var subtitle: String

    /// Initialize a new WelcomeActionView
    /// 
    /// - Parameter iconName: icon name
    /// - Parameter title: title
    /// - Parameter subtitle: subtitle
    /// 
    /// - Returns: a new WelcomeActionView
    public init(iconName: String, title: String, subtitle: String) {
        self.iconName = iconName
        self.title = title
        self.subtitle = subtitle
    }

    /// The view body.
    public var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconName)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.accentColor)
                .font(.system(size: 30, weight: .light))
                .frame(width: 24)
                .accessibilityLabel(Text("Icon"))
            VStack(alignment: .leading) {
                Text(title)
                    .bold()
                    .font(.system(size: 13))
                Text(subtitle)
                    .font(.system(size: 12))
            }
            Spacer()
        }
        .contentShape(Rectangle())
    }
}

struct WelcomeActionView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeActionView(
            iconName: "plus.square",
            title: "Create a new file",
            subtitle: "Create a new file"
        )
    }
}
