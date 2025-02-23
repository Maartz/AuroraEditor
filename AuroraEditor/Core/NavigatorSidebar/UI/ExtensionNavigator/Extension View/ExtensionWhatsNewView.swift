//
//  ExtensionWhatsNewView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/11/10.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// Extension what's new view.
struct ExtensionWhatsNewView: View {

    /// The view body.
    var body: some View {
        VStack {
            HStack {
                Text("What's New")
                    .font(.title)
                    .fontWeight(.medium)

                Spacer()

                Text("Version History")
                    .font(.system(size: 14))
                    .foregroundColor(.accentColor)
            }

            HStack(alignment: .top) {
                Text("""
##Community
""")

                Spacer()

                VStack {
                    Text("1 month ago")
                        .foregroundColor(.secondary)
                        .padding(.bottom, 1)

                    Text("Version 1.0.0")
                        .foregroundColor(.secondary)
                }

            }
            .padding(.top, 1)
        }
    }
}

struct ExtensionWhatsNewView_Previews: PreviewProvider {
    static var previews: some View {
        ExtensionWhatsNewView()
    }
}
