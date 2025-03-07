//
//  TerminalEmulatorView.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 22.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import SwiftTerm

/// # TerminalEmulatorView
///
/// A terminal emulator view.
///
/// Wraps a `LocalProcessTerminalView` from `SwiftTerm` inside a `NSViewRepresentable`
/// for use in SwiftUI.
///
public struct TerminalEmulatorView: NSViewRepresentable {

    /// Application preferences model
    @StateObject
    private var prefs: AppPreferencesModel = .shared

    /// Theme model
    @StateObject
    private var themeModel: ThemeModel = .shared

    /// Last terminal
    internal static var lastTerminal: [String: LocalProcessTerminalView] = [:]

    /// Terminal
    @State
    internal var terminal: LocalProcessTerminalView

    /// System font
    private let systemFont: NSFont = .monospacedSystemFont(ofSize: 11, weight: .medium)

    /// Font
    private var font: NSFont {
        if !prefs.preferences.terminal.customTerminalFont {
            return systemFont
        }
        return NSFont(
            name: prefs.preferences.terminal.terminalFontName,
            size: CGFloat(prefs.preferences.terminal.terminalFontSize)
        ) ?? systemFont
    }

    /// URL
    private var url: URL

    /// Initializer
    /// 
    /// - Parameter url: URL
    public init(url: URL) {
        self.url = url
        self._terminal = State(initialValue: TerminalEmulatorView.lastTerminal[url.path] ?? .init(frame: .zero))

        NotificationCenter.default.addObserver(
            forName: .openInTerminal,
            object: nil,
            queue: .main) { [self] notification in
            if let directory = notification.object as? URL {
                terminal.send(txt: "cd \"\(directory.path)\"\n")
            }
        }
    }

    /// Returns a string of a shell path to use
    ///
    /// Default implementation pulled from Example app from "SwiftTerm":
    /// ```swift
    ///    let bufsize = sysconf(_SC_GETPW_R_SIZE_MAX)
    ///    guard bufsize != -1 else { return "/bin/bash" }
    ///    let buffer = UnsafeMutablePointer<Int8>.allocate(capacity: bufsize)
    /// defer {
    ///        buffer.deallocate()
    ///    }
    ///    var pwd = passwd()
    ///    var result: UnsafeMutablePointer<passwd>? = UnsafeMutablePointer<passwd>.allocate(capacity: 1)
    ///
    /// if getpwuid_r(getuid(), &pwd, buffer, bufsize, &result) != 0 { return "/bin/bash" }
    ///    return String(cString: pwd.pw_shell)
    /// ```
    /// 
    /// - Returns: A string of the shell path
    private func getShell() -> String {
        switch prefs.preferences.terminal.shell {
        case .system:
            return autoDetectDefaultShell()
        case .bash:
            return "/bin/bash"
        case .zsh:
            return "/bin/zsh"
        }
    }

    /// Gets the default shell from the current user and returns the string of the shell path.
    /// 
    /// - Returns: A string of the shell path
    private func autoDetectDefaultShell() -> String {
        let bufsize = sysconf(_SC_GETPW_R_SIZE_MAX)
        guard bufsize != -1 else { return "/bin/bash" }
        let buffer = UnsafeMutablePointer<Int8>.allocate(capacity: bufsize)
        defer {
            buffer.deallocate()
        }
        var pwd = passwd()
        var result: UnsafeMutablePointer<passwd>? = UnsafeMutablePointer<passwd>.allocate(capacity: 1)

        if getpwuid_r(getuid(), &pwd, buffer, bufsize, &result) != 0 { return "/bin/bash" }
        return String(cString: pwd.pw_shell)
    }

    /// Returns true if the `option` key should be treated as the `meta` key.
    private var optionAsMeta: Bool {
        prefs.preferences.terminal.optionAsMeta
    }

    /// Returns the mapped array of `SwiftTerm.Color` objects of ANSI Colors
    private var colors: [SwiftTerm.Color] {
        if let selectedTheme = themeModel.selectedTheme,
           let index = themeModel.themes.firstIndex(of: selectedTheme) {
            return themeModel.themes[index].terminal.ansiColors.map { color in
                SwiftTerm.Color(hex: color)
            }
        }
        return []
    }

    /// Returns the `cursor` color of the selected theme
    private var cursorColor: NSColor {
        if let selectedTheme = themeModel.selectedTheme,
           let index = themeModel.themes.firstIndex(of: selectedTheme) {
            return NSColor(themeModel.themes[index].terminal.cursor.swiftColor)
        }
        return NSColor(.accentColor)
    }

    /// Returns the `selection` color of the selected theme
    private var selectionColor: NSColor {
        if let selectedTheme = themeModel.selectedTheme,
           let index = themeModel.themes.firstIndex(of: selectedTheme) {
            return NSColor(themeModel.themes[index].terminal.selection.swiftColor)
        }
        return NSColor(.accentColor)
    }

    /// Returns the `text` color of the selected theme
    private var textColor: NSColor {
        if let selectedTheme = themeModel.selectedTheme,
           let index = themeModel.themes.firstIndex(of: selectedTheme) {
            return NSColor(themeModel.themes[index].terminal.text.swiftColor)
        }
        return NSColor(.primary)
    }

    /// Returns the `background` color of the selected theme
    private var backgroundColor: NSColor {
        if let selectedTheme = themeModel.selectedTheme,
           let index = themeModel.themes.firstIndex(of: selectedTheme) {
            return NSColor(themeModel.themes[index].terminal.background.swiftColor)
        }
        return .windowBackgroundColor
    }

    /// returns a `NSAppearance` based on the user setting of the terminal appearance,
    /// `nil` if app default is not overriden
    private var colorAppearance: NSAppearance? {
        if prefs.preferences.terminal.darkAppearance {
            return .init(named: .darkAqua)
        }
        return nil
    }

    /// Inherited from NSViewRepresentable.makeNSView(context:).
    public func makeNSView(context: Context) -> LocalProcessTerminalView {
        terminal.processDelegate = context.coordinator
        setupSession()
        return terminal
    }

    /// Sets up the terminal session
    public func setupSession() {
        terminal.getTerminal().silentLog = true
        if TerminalEmulatorView.lastTerminal[url.path] == nil {
            let shell = getShell()
            let shellIdiom = "-" + NSString(string: shell).lastPathComponent

            // changes working directory to project root
            // TODO: Get rid of FileManager shared instance to prevent problems
            // using shared instance of FileManager might lead to problems when using
            // multiple workspaces. This works for now but most probably will need
            // to be changed later on
            FileManager.default.changeCurrentDirectoryPath(url.path)
            terminal.startProcess(executable: shell, execName: shellIdiom)
            terminal.font = font
            terminal.configureNativeColors()
            terminal.installColors(self.colors)
            terminal.caretColor = cursorColor
            terminal.selectedTextBackgroundColor = selectionColor
            terminal.nativeForegroundColor = textColor
            terminal.nativeBackgroundColor = backgroundColor
            terminal.optionAsMetaKey = optionAsMeta
        }
        terminal.appearance = colorAppearance
        scroller?.isHidden = true
        terminal.getTerminal().setCursorStyle(
            getCursorStyle(prefs.preferences.terminal.cursorStyle, shouldBlink: prefs.preferences.terminal.blinkCursor)
        )
        TerminalEmulatorView.lastTerminal[url.path] = terminal
    }

    /// Returns the scroller of the terminal
    private var scroller: NSScroller? {
        for subView in terminal.subviews {
            if let scroller = subView as? NSScroller {
                return scroller
            }
        }
        return nil
    }

    /// Updates the terminal view
    /// 
    /// - Parameter view: The terminal view
    /// - Parameter context: The context
    public func updateNSView(_ view: LocalProcessTerminalView, context: Context) {
        if view.font != font { // Fixes Memory leak
            view.font = font
        }
        view.configureNativeColors()
        view.installColors(self.colors)
        view.caretColor = cursorColor
        view.selectedTextBackgroundColor = selectionColor
        view.nativeForegroundColor = textColor
        view.nativeBackgroundColor = backgroundColor
        view.optionAsMetaKey = optionAsMeta
        view.appearance = colorAppearance
        if TerminalEmulatorView.lastTerminal[url.path] != nil {
            TerminalEmulatorView.lastTerminal[url.path] = view
        }
        view.getTerminal().softReset()
        view.feed(text: "") // send empty character to force colors to be redrawn
        view.getTerminal().setCursorStyle(
            getCursorStyle(prefs.preferences.terminal.cursorStyle, shouldBlink: prefs.preferences.terminal.blinkCursor)
        )
    }

    /// Makes a coordinator
    public func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }

    /// Get cursor style
    /// 
    /// - Parameter style: The cursor style
    /// - Parameter shouldBlink: Should the cursor blink
    /// 
    /// - Returns: The cursor style
    private func getCursorStyle(_ style: TerminalCursorStyle, shouldBlink: Bool) -> CursorStyle {
        switch style {
        case .block:
            return shouldBlink ? .blinkBlock : .steadyBlock
        case .underline:
            return shouldBlink ? .blinkUnderline : .steadyUnderline
        case .verticalBar:
            return shouldBlink ? .blinkBar : .steadyBar
        }
    }
}
