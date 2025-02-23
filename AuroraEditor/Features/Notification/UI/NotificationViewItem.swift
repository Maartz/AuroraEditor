//
//  NotificationViewItem.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import OSLog

/// The `NotificationViewItem` SwiftUI view displays individual notification items with actions and context menus.
struct NotificationViewItem: View {
    // The notification to be displayed.
    var notification: INotification

    // Observed object for managing notifications.
    @ObservedObject
    private var model: NotificationsModel = .shared

    // State to control whether to show additional actions for the notification.
    @State
    private var showActions: Bool = false

    /// Notification system logger
    private let logger = Logger(
        subsystem: "com.auroraeditor",
        category: "Notification view"
    )

    /// The view body.
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                // Display the notification icon based on severity or a default icon if none provided.
                if notification.icon == nil {
                    Image(systemName: notification.severity.iconName())
                        .symbolRenderingMode(.multicolor)
                        .font(.system(size: 14))
                        .accessibilityLabel(Text("Severity Icon"))
                } else {
                    if let url = notification.icon,
                       let nsImage = NSImage(contentsOf: url) {
                        Image(nsImage: nsImage)
                            .font(.system(size: 14))
                            .accessibilityLabel(Text("Notification Icon"))
                    }
                }

                VStack(alignment: .leading) {
                    HStack {
                        // Display the notification title.
                        Text(notification.title)
                            .foregroundColor(.primary)
                            .font(.system(size: 11, weight: .medium))

                        Spacer()

                        // Display a chevron icon for toggling additional actions (if applicable).
                        if notification.notificationType == .extensionSystem {
                            withAnimation {
                                Image(systemName: showActions ? "chevron.up" : "chevron.down")
                                    .accessibilityLabel(Text(showActions ? "Open" : "Close"))
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 11))
                            }
                        }
                    }

                    // Display the notification message.
                    Text(notification.message)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 10))
                }
            }
            .onTapGesture {
                // Toggle additional actions when tapping the title (if applicable).
                if notification.notificationType == .extensionSystem {
                    withAnimation {
                        showActions.toggle()
                    }
                }
            }
            .accessibilityAddTraits(.isButton)

            // Display additional actions (if expanded).
            if showActions {
                Button {
                    // Action to be performed when the button is tapped.
                } label: {
                    Spacer()
                    Text("UPDATE")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 11))
                    Spacer()
                }
                .shadow(radius: 0)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .buttonStyle(.bordered)
            }
        }
        .padding(5)
        .onTapGesture {
            if notification.notificationType == .update {
            }
        }
        .accessibilityAddTraits(.isButton)
        .contextMenu {
            // Context menu items for the notification.
            Button("Copy") {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(notification.message, forType: .string)
            }

            Button("Ignore Notification") {
                // Action to ignore the notification.
                removeNotificationAtIndex()
            }

            Button("Don’t Show Again...") {
                // Action to hide the notification permanently.
                removeNotificationAtIndex()
                var updatedNotification = notification
                updatedNotification.neverShowAgain?.id = UUID().uuidString
                updatedNotification.neverShowAgain?.scope = .WORKSPACE
                LocalStorage().saveDoNotShowNotification(notification: updatedNotification)
            }
        }
    }

    /// Removes the current notification from the model's notifications array.
    private func removeNotificationAtIndex() {
        if let index = self.model.notifications.firstIndex(of: notification) {
            self.model.notifications.remove(at: index)
        }
    }
}
