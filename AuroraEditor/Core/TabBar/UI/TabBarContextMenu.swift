//
//  TabBarContextMenu.swift
//  Aurora Editor
//
//  Created by Khan Winter on 6/4/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    /// Adds a context menu to the view.
    /// 
    /// - Parameter item: The item to add the context menu to.
    /// - Parameter workspace: The workspace document.
    /// - Parameter isTemporary: Whether the tab is temporary.
    /// 
    /// - Returns: The modified view.
    func tabBarContextMenu(item: TabBarItemRepresentable,
                           workspace: WorkspaceDocument,
                           isTemporary: Bool) -> some View {
        modifier(TabBarContextMenu(item: item, workspace: workspace, isTemporary: isTemporary))
    }
}

/// A view modifier that adds a context menu to the view.
struct TabBarContextMenu: ViewModifier {
    /// Initialize the context menu.
    /// 
    /// - Parameter item: The item to add the context menu to.
    /// - Parameter workspace: The workspace document.
    /// - Parameter isTemporary: Whether the tab is temporary.
    /// 
    /// - Returns: A new context menu view modifier.
    init(item: TabBarItemRepresentable,
         workspace: WorkspaceDocument,
         isTemporary: Bool) {
        self.item = item
        self.workspace = workspace
        self.isTemporary = isTemporary
    }

    /// The workspace document.
    @ObservedObject
    var workspace: WorkspaceDocument

    /// The tab bar item.
    private var item: TabBarItemRepresentable

    /// Whether the tab is temporary.
    private var isTemporary: Bool

    /// The view body.
    func body(content: Content) -> some View { // swiftlint:disable:this function_body_length
        content.contextMenu(menuItems: {
            Group {
                Button("Close Tab") {
                    withAnimation {
                        workspace.closeTab(item: item.tabID)
                    }
                }
                .keyboardShortcut("w", modifiers: [.command])

                Button("Close Other Tabs") {
                    withAnimation {
                        workspace.closeTab(where: { $0 != item.tabID })
                    }
                }
                Button("Close Tabs to the Right") {
                    withAnimation {
                        workspace.closeTabs(after: item.tabID)
                    }
                }
                // Disable this option when current tab is the last one.
                .disabled(workspace.selectionState.openedTabs.last?.id == item.tabID.id)

                Button("Close All") {
                    withAnimation {
                        workspace.closeTabs(items: workspace.selectionState.openedTabs)
                    }
                }

                if isTemporary {
                    Button("Keep Open") {
                        workspace.convertTemporaryTab()
                    }
                }
            }

            Divider()

            if let item = item as? FileSystemClient.FileItem {
                Group {
                    Button("Copy Path") {
                        copyPath(item: item)
                    }

                    Button("Copy Relative Path") {
                        copyRelativePath(item: item)
                    }
                }

                Divider()

                Group {
                    Button("Show in Finder") {
                        item.showInFinder()
                    }

                    Button("Reveal in Project Navigator") {
                        workspace.listenerModel.highlightedFileItem = item
                    }

                    Button("Open in New Window") {

                    }
                    .disabled(true)
                }
            }
        })
    }

    // MARK: - Actions

    /// Copies the absolute path of the given `FileItem`
    /// 
    /// - Parameter item: The `FileItem` to use.
    private func copyPath(item: FileSystemClient.FileItem) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(item.url.standardizedFileURL.path, forType: .string)
    }

    /// Copies the relative path from the workspace folder to the given file item to the pasteboard.
    /// 
    /// - Parameter item: The `FileItem` to use.
    private func copyRelativePath(item: FileSystemClient.FileItem) {
        guard let rootPath = workspace.fileSystemClient?.folderURL else {
            return
        }
        // Calculate the relative path
        var rootComponents = rootPath.standardizedFileURL.pathComponents
        var destinationComponents = item.url.standardizedFileURL.pathComponents

        // Remove any same path components
        while !rootComponents.isEmpty && !destinationComponents.isEmpty
                && rootComponents.first == destinationComponents.first {
            rootComponents.remove(at: 0)
            destinationComponents.remove(at: 0)
        }

        // Make a "../" for each remaining component in the root URL
        var relativePath: String = String(repeating: "../", count: rootComponents.count)
        // Add the remaining components for the destination url.
        relativePath += destinationComponents.joined(separator: "/")

        // Copy it to the clipboard
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(relativePath, forType: .string)
    }
}
