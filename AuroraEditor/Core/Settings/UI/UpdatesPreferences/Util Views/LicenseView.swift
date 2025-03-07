//
//  LicenseView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/10/06.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A view that represents the license view.
struct LicenseView: View {
    /// A binding to close the sheet
    @Binding
    var closeSheet: Bool

    /// The update model
    @State
    var model: UpdateObservedModel?

    /// The view body
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                Text(getLicenseCredits())
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 11))
                    .padding(15)
            }

            Divider()

            HStack {
                Spacer()

                Button {
                    closeSheet.toggle()
                } label: {
                    Text("Disagree")
                }

                Button {
                    closeSheet.toggle()
                    model?.updateState = .inProgress
                } label: {
                    Text("Agree")
                        .padding(.horizontal)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(width: 450, height: 350)
        .padding()
    }

    /// Get the license credits
    public func getLicenseCredits() -> String {
        if let filepath = Bundle.main.path(forResource: "Credits", ofType: "md") {
            do {
                let contents = try String(contentsOfFile: filepath)
                return contents
            } catch {
                return "Could not load credits for Aurora Editor."
            }
        } else {
            return "Credit file not found."
        }
    }
}
