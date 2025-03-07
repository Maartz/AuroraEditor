//
//  AcknowledgementsView.swift
//  Aurora Editor
//
//  Created by Shivesh M M on 4/4/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// The view that displays the acknowledgements
public struct AcknowledgementsView: View {
    @ObservedObject
    /// The view model
    private var model: AcknowledgementsModel

    /// Initializes the view
    public init() {
        self.model = .init()
    }

    /// Initializes the view
    /// 
    /// - Parameter dependencies: The dependencies
    init(_ dependencies: [Dependency]) {
        self.model = .init(dependencies)
    }

    /// The view body
    public var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Dependencies")
                .font(.system(size: 18, weight: .semibold)).padding([.leading, .top], 10.0)
            ScrollView {
                if model.acknowledgements.isEmpty {
                    Text("Failed to load.")
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(model.acknowledgements, id: \.name) { acknowledgement in
                            AcknowledgementRow(acknowledgement: acknowledgement)
                                .listRowBackground(Color.clear)
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.bottom)
                }
            }
        }
    }

    /// Shows the window
    public func showWindow(width: CGFloat, height: CGFloat) {
        AcknowledgementWindowController(
            view: self,
            size: NSSize(
                width: width,
                height: height
            )
        ).showWindow(nil)
    }
}

/// The view model for the acknowledgements
struct AcknowledgementRow: View {
    @Environment(\.openURL)
    /// The open URL environment
    var openURL

    /// Acknowledgements
    var acknowledgement: Dependency

    /// The view body
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(acknowledgement.name)
                .bold()
            Text(acknowledgement.version)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.leading, -5.0)
            Spacer()
            Button(action: {
                openURL(acknowledgement.repositoryURL)
            }, label: {
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(Color(nsColor: .tertiaryLabelColor))
                    .accessibilityLabel(Text("Go to"))
            }).buttonStyle(.plain)
        }
    }
}

/// The window controller for the acknowledgements
final class AcknowledgementWindowController: NSWindowController {
    /// Initializes the window controller with the given view and size
    /// 
    /// - Parameter view: The view to display in the window
    /// - Parameter size: The size of the window
    convenience init<T: View>(view: T, size: NSSize) {
        let hostingController = NSHostingController(rootView: view)
        // New window holding our SwiftUI view
        let window = NSWindow(contentViewController: hostingController)
        self.init(window: window)
        window.setContentSize(size)
        window.styleMask.remove(.resizable)
        window.styleMask.insert(.fullSizeContentView)
        window.alphaValue = 0.5
        window.styleMask.remove(.miniaturizable)
    }

    /// The event handler for the escape key
    private var escapeDetectEvent: Any?

    /// Shows the window
    /// 
    /// - Parameter sender: The sender
    override func showWindow(_ sender: Any?) {
        window?.center()
        window?.alphaValue = 0.0

        super.showWindow(sender)

        window?.animator().alphaValue = 1.0

        // Close the window when the escape key is pressed
        escapeDetectEvent = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard event.keyCode == 53 else { return event }

            self.closeAnimated()

            return nil
        }

        window?.collectionBehavior = [.transient, .ignoresCycle]
        window?.isMovableByWindowBackground = true
        window?.title = "Acknowledgements"
    }

    /// De-initializes the window controller
    deinit {
        self.loggerinfo("Acknowledgement window controller de-init'd")
        if let escapeDetectEvent = escapeDetectEvent {
            NSEvent.removeMonitor(escapeDetectEvent)
        }
    }

    /// Closes the window
    func closeAnimated() {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = 0.4
        NSAnimationContext.current.completionHandler = {
            if let escapeDetectEvent = self.escapeDetectEvent {
                NSEvent.removeMonitor(escapeDetectEvent)
            }
            self.close()
        }
        window?.animator().alphaValue = 0.0
        NSAnimationContext.endGrouping()
    }
}

struct Acknowledgements_Previews: PreviewProvider {
    static var previews: some View {
        AcknowledgementsView([
            Dependency(name: "Hi", repositoryLink: "Test", version: "1.2.3"),
            Dependency(name: "Hi", repositoryLink: "Test", version: "1.2.3"),
            Dependency(name: "Hi", repositoryLink: "Test", version: "1.2.3"),
            Dependency(name: "Hi", repositoryLink: "Test", version: "1.2.3"),
            Dependency(name: "Hi", repositoryLink: "Test", version: "1.2.3")
        ]).preferredColorScheme(.dark)
        AcknowledgementsView([
            Dependency(name: "Hi", repositoryLink: "Test", version: "1.2.3"),
            Dependency(name: "Hi", repositoryLink: "Test", version: "1.2.3"),
            Dependency(name: "Hi", repositoryLink: "Test", version: "1.2.3"),
            Dependency(name: "Hi", repositoryLink: "Test", version: "1.2.3"),
            Dependency(name: "Hi", repositoryLink: "Test", version: "1.2.3")
        ]).preferredColorScheme(.light)
    }
}
