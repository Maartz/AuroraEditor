//
//  TabBarItem.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 17.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import OSLog

/// Tab bar item view.
struct TabBarItem: View {

    /// Is fullscreen
    @Environment(\.isFullscreen)
    private var isFullscreen

    /// Active state
    @Environment(\.controlActiveState)
    var activeState

    /// Color scheme
    @Environment(\.colorScheme)
    var colorScheme

    /// Workspace document
    @EnvironmentObject
    var workspace: WorkspaceDocument

    /// Application preferences model
    @StateObject
    var prefs: AppPreferencesModel = .shared

    /// Hover state
    @State
    var isHovering: Bool = false

    /// Hover state for close button
    @State
    var isHoveringClose: Bool = false

    /// Pressing close button
    @State
    var isPressingClose: Bool = false

    /// Is appeared
    @State
    var isAppeared: Bool = false

    /// Expected width
    @Binding
    private var expectedWidth: CGFloat

    /// Tab bar item
    var item: TabBarItemRepresentable

    /// Is temporary
    @State
    var isTemporary: Bool = true

    /// Is active
    var isActive: Bool {
        item.tabID == workspace.selectionState.selectedId
    }

    /// Switch action
    func switchAction() {
        // Only set the `selectedId` when they are not equal to avoid performance issue for now.
        if workspace.selectionState.selectedId != item.tabID {
            workspace.selectionState.selectedId = item.tabID
        }
    }

    /// Close action
    func closeAction() {
        withAnimation(.easeOut(duration: 0.20)) {
            workspace.closeTab(item: item.tabID)
        }
    }

    /// Initialize the tab bar item view.
    /// 
    /// - Parameter expectedWidth: The expected width of the tab bar item.
    /// - Parameter item: The tab bar item.
    init(
        expectedWidth: Binding<CGFloat>,
        item: TabBarItemRepresentable
    ) {
        self._expectedWidth = expectedWidth
        self.item = item
    }

    /// Content
    @ViewBuilder
    var content: some View {
        HStack(spacing: 0.0) {
            TabDivider()
                .opacity(isActive ? 0.0 : 1.0)
                .padding(.top, 0)
            // Tab content (icon and text).
            iconTextView
            .opacity(
                // Inactive states for tab bar item content.
                activeState != .inactive
                ? 1.0
                : (isActive ? 0.6 : 0.4)
            )
            TabDivider()
                .opacity(isActive ? 0.0 : 1.0)
                .padding(.top, 0)
        }
        .onAppear {
            isTemporary = workspace.selectionState.temporaryTab == item.tabID
            ExtensionsManager.shared.sendEvent(
                event: "didActivateTab",
                parameters: ["file": item.tabID.fileRepresentation]
            )
        }
        .onChange(of: workspace.selectionState.temporaryTab) { _ in
            isTemporary = workspace.selectionState.temporaryTab == item.tabID
        }
        .onChange(of: isActive, perform: { newValue in
            ExtensionsManager.shared.sendEvent(
                event: newValue ? "didActivateTab" : "didDeactivateTab",
                parameters: ["file": item.tabID.fileRepresentation]
            )
        })
        .foregroundColor(
            isActive
            ? (colorScheme != .dark ? Color(nsColor: .controlAccentColor) : .primary)
            : .primary
        )
        .frame(maxHeight: .infinity) // To vertically max-out the parent (tab bar) area.
        .contentShape(Rectangle()) // Make entire area clickable.
        .onHover { hover in
            isHovering = hover
            DispatchQueue.main.async {
                if hover {
                    NSCursor.arrow.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
    }

    /// The view body.
    var body: some View {
        Button(
            action: switchAction,
            label: { content }
        )
        .buttonStyle(TabBarItemButtonStyle())
        .simultaneousGesture(
            TapGesture(count: 2)
                .onEnded { _ in
                    if isTemporary {
                        workspace.convertTemporaryTab()
                    }
                }
        )
        .background {
                ZStack {
                    // This layer of background is to hide dividers of other tab bar items
                    // because the original background above is translucent (by opacity).
                    TabBarXcodeBackground()
                    if isActive {
                        Color(nsColor: .controlAccentColor)
                            .saturation(
                                colorScheme == .dark
                                ? (activeState != .inactive ? 0.60 : 0.75)
                                : (activeState != .inactive ? 0.90 : 0.85)
                            )
                            .opacity(
                                colorScheme == .dark
                                ? (activeState != .inactive ? 0.50 : 0.35)
                                : (activeState != .inactive ? 0.18 : 0.12)
                            )
                            .hueRotation(.degrees(-5))
                    }
                }
                .animation(.easeInOut(duration: 0.08), value: isHovering)
        }
        .padding(
            // This padding is to avoid background color overlapping with top divider.
            .top, 1
        )
        .offset(
            x: isAppeared ? 0 : -14,
            y: 0
        )
        .opacity(isAppeared ? 1.0 : 0.0)
        .zIndex(isActive ? 1 : 0)
        .onAppear {
            if (isTemporary && workspace.selectionState.previousTemporaryTab == nil)
                || !(isTemporary && workspace.selectionState.previousTemporaryTab != item.tabID) {
                withAnimation(.easeOut(duration: 0.20)) {
                    isAppeared = true
                }
            } else {
                withAnimation(.linear(duration: 0.0)) {
                    isAppeared = true
                }
            }
        }
        .id(item.tabID)
        .tabBarContextMenu(item: item, workspace: workspace, isTemporary: isTemporary)
    }
}
