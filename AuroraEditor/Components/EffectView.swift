//
//  BlurView.swift
//  Aurora Editor
//
//  Created by Rehatbir Singh on 15/03/2022.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// A SwiftUI Wrapper for `NSVisualEffectView`
///
/// ## Usage
/// ```swift
/// EffectView(material: .headerView, blendingMode: .withinWindow)
/// ```
public struct EffectView: NSViewRepresentable {
    /// The material to use for the effect view.
    private let material: NSVisualEffectView.Material

    /// The blending mode to use for the effect view.
    private let blendingMode: NSVisualEffectView.BlendingMode

    /// A Boolean value indicating whether to emphasize the look of the material.
    private let emphasized: Bool

    /// Initializes the
    /// [`NSVisualEffectView`](https://developer.apple.com/documentation/appkit/nsvisualeffectview)
    /// with a
    /// [`Material`](https://developer.apple.com/documentation/appkit/nsvisualeffectview/material) and
    /// [`BlendingMode`](https://developer.apple.com/documentation/appkit/nsvisualeffectview/blendingmode)
    ///
    /// By setting the
    /// [`emphasized`](https://developer.apple.com/documentation/appkit/nsvisualeffectview/1644721-isemphasized)
    /// flag the emphasized state of the material will be used if available.
    ///
    /// - Parameters:
    ///   - material: The material to use. Defaults to `.headerView`.
    ///   - blendingMode: The blending mode to use. Defaults to `.withinWindow`.
    ///   - emphasized:A Boolean value indicating whether to emphasize the look of the material. Defaults to `false`.
    public init(
        _ material: NSVisualEffectView.Material = .headerView,
        blendingMode: NSVisualEffectView.BlendingMode = .withinWindow,
        emphasized: Bool = false
    ) {
        self.material = material
        self.blendingMode = blendingMode
        self.emphasized = emphasized
    }

    /// Makes the `NSVisualEffectView` with the provided `material`, `blendingMode` and `emphasized` flag.
    public func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.isEmphasized = emphasized
        view.state = .followsWindowActiveState
        return view
    }

    /// Updates the `NSVisualEffectView` with the provided `material` and `blendingMode`.
    public func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }

    /// Returns the system selection style as an ``EffectView`` if the `condition` is met.
    /// Otherwise it returns `Color.clear`
    /// 
    /// - Parameter condition: The condition of when to apply the background. Defaults to `true`.
    /// - Returns: A View
    @ViewBuilder
    public static func selectionBackground(_ condition: Bool = true) -> some View {
        if condition {
            EffectView(.selection, blendingMode: .withinWindow, emphasized: true)
        } else {
            Color.clear
        }
    }
}
