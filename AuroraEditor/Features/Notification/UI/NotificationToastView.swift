//
//  NotificationToastView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 16/09/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The `NotificationToastView` SwiftUI view displays a notification toast with title and message.
struct NotificationToastView: View {
    // Observed object for managing notifications.
    @ObservedObject
    private var model: NotificationsModel = .shared

    // Environment value for color scheme.
    @Environment(\.colorScheme)
    var colorScheme

    // The notification to display.
    @State
    public var notification: INotification

    /// The view body.
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                // Notification icon.
                NotificationIcon(notification: notification)
                    .frame(maxWidth: 24, maxHeight: 24)

                // Notification source or identifier.
                Text(notification.title)
                    .fontWithLineHeight(fontSize: 12, lineHeight: 7)
                    .foregroundColor(.secondary)

                Spacer()

                Text(getCurrentTimeStamp())
                    .fontWithLineHeight(fontSize: 11, lineHeight: 7)
                    .foregroundColor(.secondary)

                // Close button for dismissing the notification.
                if model.hoveringOnToast {
                    Image(systemName: "xmark")
                        .font(.system(size: 11))
                        .frame(maxWidth: 24, maxHeight: 24)
                        .accessibilityLabel(Text("Dismiss"))
                        .onTapGesture {
                            ExtensionsManager.shared.sendEvent(
                                event: "didDismissNotification",
                                parameters: [
                                    "identifier": notification.id,
                                    "extension": notification.sender
                                ]
                            )

                            model.showNotificationToast = false
                        }
                        .accessibilityAddTraits(.isButton)
                }
            }

            // Message content of the notification.
            Text(notification.message)
                .fontWeight(.regular)
                .fontWithLineHeight(fontSize: 13, lineHeight: 8)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
        .frame(minWidth: 350, minHeight: 75)
        .background(colorScheme == .light ? .white : Color(hex: "#252525"))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(radius: 1)
        .onHover { hovering in
            // Track if the mouse is hovering over the notification for interaction.
            model.hoveringOnToast = hovering
        }
        .onTapGesture {
            ExtensionsManager.shared.sendEvent(
                event: "didClickOnNotification",
                parameters: [
                    "identifier": notification.id,
                    "extension": notification.sender,
                    "title": notification.title,
                    "message": notification.message
                ]
            )
        }
        .accessibilityAddTraits(.isButton)
    }

    /// Get the current time stamp.
    /// 
    /// - Returns: The current time stamp.
    func getCurrentTimeStamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
}
